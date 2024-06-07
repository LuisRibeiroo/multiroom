import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:signals/signals_flutter.dart';
import 'package:toastification/toastification.dart';
import 'package:udp/udp.dart';

import '../../../../core/enums/page_state.dart';
import '../../../../core/extensions/list_extensions.dart';
import '../../../../core/interactor/controllers/base_controller.dart';
import '../../../../core/models/equalizer_model.dart';
import '../../../../core/models/frequency.dart';
import '../../../../core/models/channel_model.dart';
import '../../../../core/models/zone_model.dart';
import '../../../../core/utils/debouncer.dart';
import '../models/device_model.dart';
import '../utils/multiroom_command_builder.dart';

class HomePageController extends BaseController {
  HomePageController() : super(InitialState()) {
    _init();

    device.subscribe((value) async {
      if (value.isEmpty) {
        return;
      }

      currentZone.value = value.zones.first;

      equalizers.addOrReplace(currentZone.value.equalizer);
    });

    currentZone.subscribe((value) async {
      if (value.isEmpty) {
        return;
      }

      final idx = device.value.zones
          .indexWhere((zone) => currentZone.value.name == zone.name);

      untracked(() {
        device.value.zones[idx] = value;
      });

      channels.value = value.channels;

      if (currentZone.previousValue!.id != currentZone.value.id) {
        await run(_updateAllDeviceData);
      }
    });
  }

  late UDP udpServer;
  late Socket _socket;

  final equalizers = listSignal(
    [
      EqualizerModel.builder(name: "Rock", value: 80),
      EqualizerModel.builder(name: "Pop", value: 60),
      EqualizerModel.builder(name: "Jazz", value: 65),
      EqualizerModel.builder(name: "Flat", value: 50),
    ],
    debugLabel: "equalizers",
  );

  final channels = listSignal<ChannelModel>(
    [],
    debugLabel: "channels",
  );

  final _logger = Logger(
    printer: SimplePrinter(colors: true, printTime: true),
  );

  final _serverTimeOut = const Duration(seconds: 30);

  final host = "192.168.0.101".toSignal(debugLabel: "host");
  final port = "4998".toSignal(debugLabel: "port");
  final isConnected = false.toSignal(debugLabel: "isConnected");
  final isServerListening = false.toSignal(debugLabel: "isServerListening");
  final device = DeviceModel.empty().toSignal(debugLabel: "device");
  final currentZone = ZoneModel.empty().toSignal(debugLabel: "currentZone");
  final currentChannel =
      ChannelModel.empty().toSignal(debugLabel: "currentChannel");

  final _writeDebouncer = Debouncer(delay: Durations.short4);
  late StreamIterator<Uint8List> streamIterator;

  Future<void> _init() async {
    _logger.d("LOCAL IP --> ${await NetworkInfo().getWifiIP()}");

    udpServer = await UDP.bind(
      Endpoint.unicast(
        InternetAddress.anyIPv4,
        port: const Port(4055),
      ),
    );

    effect(() {
      if (isServerListening.value) {
        _logger.d(
            "UDP LISTENING ON --> ${udpServer.local.address?.address}:${udpServer.local.port?.value} ");
      } else {
        _logger.d("UDP SERVER CLOSED");
      }
    });
  }

  Future<void> test() async {
    final t = await _readCommand(
        MultiroomCommandBuilder.getZoneMode(zone: currentZone.value));

    _logger.d("ZONE MODE --> $t");
  }

  Future<void> toggleConnection() async {
    if (isConnected.value) {
      _socket.close();
      isConnected.value = false;

      device.value = device.initialValue;
      currentZone.value = currentZone.initialValue;
    } else {
      try {
        _socket = await run(
          () => Socket.connect(
            host.value,
            int.parse(port.value),
            timeout: const Duration(seconds: 5),
          ),
        );

        streamIterator = StreamIterator(_socket);

        isConnected.value = true;

        device.value = DeviceModel.builder(
          name: "Master 1",
          ip: host.value,
          port: int.parse(port.value),
        );
      } catch (exception) {
        _logger.e(exception);
        setError(exception as Exception);
      }
    }
  }

  Future<void> toggleUdpServer() async {
    if (isServerListening.value) {
      udpServer.close();
      isServerListening.value = false;
    } else {
      try {
        isServerListening.value = true;
        udpServer.asStream(timeout: _serverTimeOut).listen((datagram) {
          if (datagram == null) {
            return;
          }

          final data = String.fromCharCodes(datagram.data);

          _logger.d(
              "UDP DATA RECEIVED --> $data | FROM ${datagram.address.address}:${datagram.port}");

          host.value = datagram.address.address;
          port.value = 4998.toString();

          udpServer.close();
          isServerListening.value = false;

          toastification.show(
            type: ToastificationType.success,
            title: const Text("Conexão recebida"),
            description: Text("IP: ${datagram.address.address}"),
            autoCloseDuration: const Duration(seconds: 2),
          );
        });
      } catch (exception) {
        _logger.e(exception);
        setError(exception as Exception);
      }
    }
  }

  void setCurrentZone(ZoneModel zone) {
    currentZone.value = zone;
  }

  void setCurrentChannel(ChannelModel channel) {
    final channelIndex = channels.indexWhere((c) => c.name == channel.name);
    final tempList = List<ChannelModel>.from(channels);

    tempList[channelIndex] = channel;

    currentZone.value = currentZone.value.copyWith(channels: tempList);
    currentChannel.value = channel;

    _debounceSendCommand(
      MultiroomCommandBuilder.setChannel(
        zone: currentZone.value,
        channel: channel,
      ),
    );
  }

  void setBalance(int balance) {
    currentZone.value = currentZone.value.copyWith(balance: balance);

    _debounceSendCommand(
      MultiroomCommandBuilder.setBalance(
        zone: currentZone.value,
        balance: balance,
      ),
    );
  }

  void setVolume(int volume) {
    currentZone.value = currentZone.value.copyWith(volume: volume);

    _debounceSendCommand(
      MultiroomCommandBuilder.setVolume(
        zone: currentZone.value,
        volume: volume,
      ),
    );
  }

  Future<void> setEqualizer(int equalizerIndex) async {
    currentZone.value =
        currentZone.value.copyWith(equalizer: equalizers[equalizerIndex]);

    for (var freq in currentZone.value.equalizer.frequencies) {
      _debounceSendCommand(
        MultiroomCommandBuilder.setEqualizer(
          zone: currentZone.value,
          frequency: freq,
          gain: freq.value,
        ),
      );

      // Delay to avoid sending commands too fast
      await Future.delayed(Durations.medium1);
    }
  }

  void setFrequency(
    EqualizerModel equalizer,
    Frequency frequency,
  ) {
    final freqIndex =
        equalizer.frequencies.indexWhere((f) => f.name == frequency.name);
    final tempList = List<Frequency>.from(equalizer.frequencies);

    tempList[freqIndex] = equalizer.frequencies[freqIndex]
        .copyWith(value: frequency.value.toInt());

    currentZone.value = currentZone.value
        .copyWith(equalizer: equalizer.copyWith(frequencies: tempList));

    _debounceSendCommand(
      MultiroomCommandBuilder.setEqualizer(
        zone: currentZone.value,
        frequency: frequency,
        gain: frequency.value,
      ),
    );
  }

  Future<void> _writeCommand(String cmd) async {
    _socket.writeln(cmd);
    _logger.d("SENT >>> $cmd");

    if (await streamIterator.moveNext()) {
      final stringResponse = String.fromCharCodes(streamIterator.current);
      _logger.d("RECEIVED <<< $stringResponse");

      if (stringResponse.contains("OK") == false) {
        setError(Exception("Resposta não esperada: $stringResponse"));
      }
    }
  }

  void _debounceSendCommand(String cmd) {
    _writeDebouncer(() => _writeCommand(cmd));
  }

  Future<String> _readCommand(String cmd) async {
    _socket.writeln(cmd);
    _logger.d("SENT >>> $cmd");

    return await _listenOnIterator();
  }

  Future<void> _updateAllDeviceData() async {
    // _writeCommand("UPDATE ALL DATA");

    final channel = await _readCommand(
        MultiroomCommandBuilder.getChannel(zone: currentZone.value));

    await Future.delayed(Durations.short3);

    final volume = await _readCommand(
        MultiroomCommandBuilder.getVolume(zone: currentZone.value));

    await Future.delayed(Durations.short3);
    final balance = await _readCommand(
        MultiroomCommandBuilder.getBalance(zone: currentZone.value));

    await Future.delayed(Durations.short3);
    final f32 = await _readCommand(
      MultiroomCommandBuilder.getEqualizer(
        zone: currentZone.value,
        frequency: currentZone.value.equalizer.frequencies[0],
      ),
    );

    await Future.delayed(Durations.short3);
    final f64 = await _readCommand(
      MultiroomCommandBuilder.getEqualizer(
        zone: currentZone.value,
        frequency: currentZone.value.equalizer.frequencies[1],
      ),
    );

    await Future.delayed(Durations.short3);
    final f125 = await _readCommand(
      MultiroomCommandBuilder.getEqualizer(
        zone: currentZone.value,
        frequency: currentZone.value.equalizer.frequencies[2],
      ),
    );

    await Future.delayed(Durations.short3);
    final f250 = await _readCommand(
      MultiroomCommandBuilder.getEqualizer(
        zone: currentZone.value,
        frequency: currentZone.value.equalizer.frequencies[3],
      ),
    );

    await Future.delayed(Durations.short3);
    final f500 = await _readCommand(
      MultiroomCommandBuilder.getEqualizer(
        zone: currentZone.value,
        frequency: currentZone.value.equalizer.frequencies[4],
      ),
    );

    await Future.delayed(Durations.short3);
    final f1000 = await _readCommand(
      MultiroomCommandBuilder.getEqualizer(
        zone: currentZone.value,
        frequency: currentZone.value.equalizer.frequencies[5],
      ),
    );

    await Future.delayed(Durations.short3);
    final f2000 = await _readCommand(
      MultiroomCommandBuilder.getEqualizer(
        zone: currentZone.value,
        frequency: currentZone.value.equalizer.frequencies[6],
      ),
    );

    await Future.delayed(Durations.short3);
    final f4000 = await _readCommand(
      MultiroomCommandBuilder.getEqualizer(
        zone: currentZone.value,
        frequency: currentZone.value.equalizer.frequencies[7],
      ),
    );

    await Future.delayed(Durations.short3);
    final f8000 = await _readCommand(
      MultiroomCommandBuilder.getEqualizer(
        zone: currentZone.value,
        frequency: currentZone.value.equalizer.frequencies[8],
      ),
    );

    await Future.delayed(Durations.short3);
    final f16000 = await _readCommand(
      MultiroomCommandBuilder.getEqualizer(
        zone: currentZone.value,
        frequency: currentZone.value.equalizer.frequencies[9],
      ),
    );

    final equalizer = currentZone.value.equalizer;

    currentChannel.value = channels.firstWhere(
      (c) => c.id == channel,
      orElse: () => ChannelModel.builder(index: 1, name: channel),
    );
    currentZone.value = currentZone.value.copyWith(
      volume: int.tryParse(volume) ?? currentZone.value.volume,
      balance: int.tryParse(balance) ?? currentZone.value.balance,
      equalizer: equalizer.copyWith(
        frequencies: [
          equalizer.frequencies[0].copyWith(value: int.parse(f32)),
          equalizer.frequencies[1].copyWith(value: int.parse(f64)),
          equalizer.frequencies[2].copyWith(value: int.parse(f125)),
          equalizer.frequencies[3].copyWith(value: int.parse(f250)),
          equalizer.frequencies[4].copyWith(value: int.parse(f500)),
          equalizer.frequencies[5].copyWith(value: int.parse(f1000)),
          equalizer.frequencies[6].copyWith(value: int.parse(f2000)),
          equalizer.frequencies[7].copyWith(value: int.parse(f4000)),
          equalizer.frequencies[8].copyWith(value: int.parse(f8000)),
          equalizer.frequencies[9].copyWith(value: int.parse(f16000)),
        ],
      ),
    );
  }

  Future<String> _listenOnIterator() async {
    while (await streamIterator.moveNext() == false) {
      await Future.delayed(Durations.short2);
    }

    final response = String.fromCharCodes(streamIterator.current);
    _logger.d("RECEIVED <<< $response");

    return MultiroomCommandBuilder.parseResponse(response)!;
  }
}
