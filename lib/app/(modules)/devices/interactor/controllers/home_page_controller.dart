import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:signals/signals_flutter.dart';
import 'package:udp/udp.dart';

import '../../../../core/enums/page_state.dart';
import '../../../../core/extensions/list_extensions.dart';
import '../../../../core/interactor/controllers/base_controller.dart';
import '../../../../core/models/equalizer_model.dart';
import '../../../../core/models/frequency.dart';
import '../../../../core/models/input_model.dart';
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
      currentInput.value = value.inputs.first;

      equalizers.addOrReplace(currentZone.value.equalizer);
    });

    currentZone.subscribe((value) async {
      if (value.isEmpty) {
        return;
      }

      final idx = device.value.zones
          .indexWhere((zone) => currentZone.value.name == zone.name);

      device.value.zones[idx] = value;

      if (currentZone.previousValue!.id != currentZone.value.id) {
        await run(_updateAllDeviceData);
      }
    });

    currentInput.subscribe((value) {
      if (value.isEmpty) {
        return;
      }

      final idx = device.value.inputs
          .indexWhere((input) => currentInput.value.name == input.name);

      device.value.inputs[idx] = value;
    });
  }

  late UDP udpServer;
  late Socket _socket;

  final equalizers = listSignal([
    EqualizerModel.builder(name: "Rock", value: 80),
    EqualizerModel.builder(name: "Pop", value: 60),
    EqualizerModel.builder(name: "Jazz", value: 65),
    EqualizerModel.builder(name: "Flat", value: 50),
  ]);

  final _logger = Logger();

  final _serverTimeOut = const Duration(seconds: 30);

  final host = "192.168.0.101".toSignal(debugLabel: "host");
  final port = "4998".toSignal(debugLabel: "port");
  final isConnected = false.toSignal(debugLabel: "isConnected");
  final isServerListening = false.toSignal(debugLabel: "isServerListening");
  final device = DeviceModel.empty().toSignal(debugLabel: "device");
  final currentZone = ZoneModel.empty().toSignal(debugLabel: "currentZone");
  final currentInput = InputModel.empty().toSignal(debugLabel: "currentInput");

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
        _logger.d("UDP SERVER CLOSED");
      } else {
        _logger.d(
            "UDP LISTENING ON --> ${udpServer.local.address?.address}:${udpServer.local.port?.value} ");
      }
    });
  }

  Future<void> toggleConnection() async {
    if (isConnected.value) {
      _socket.close();
      isConnected.value = false;

      device.value = device.initialValue;
      currentZone.value = currentZone.initialValue;
      currentInput.value = currentInput.initialValue;
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

  void setCurrentInput(InputModel input) {
    currentInput.value = input;

    _debounceSendCommand(
      MultiroomCommandBuilder.setChannel(
        zone: currentZone.value,
        input: input,
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

    // final volume = await _readCommand(
    //     MultiroomCommandBuilder.getVolume(zone: currentZone.value));

    // final balance = await _readCommand(
    //     MultiroomCommandBuilder.getBalance(zone: currentZone.value));

    // final f32 = await _readCommand(
    //   MultiroomCommandBuilder.getEqualizer(
    //     zone: currentZone.value,
    //     frequency: currentZone.value.equalizer.frequencies[0],
    //   ),
    // );
    // final f64 = await _readCommand(
    //   MultiroomCommandBuilder.getEqualizer(
    //     zone: currentZone.value,
    //     frequency: currentZone.value.equalizer.frequencies[1],
    //   ),
    // );

    // final f125 = await _readCommand(
    //   MultiroomCommandBuilder.getEqualizer(
    //     zone: currentZone.value,
    //     frequency: currentZone.value.equalizer.frequencies[2],
    //   ),
    // );
    // final f250 = await _readCommand(
    //   MultiroomCommandBuilder.getEqualizer(
    //     zone: currentZone.value,
    //     frequency: currentZone.value.equalizer.frequencies[3],
    //   ),
    // );
    // final f500 = await _readCommand(
    //   MultiroomCommandBuilder.getEqualizer(
    //     zone: currentZone.value,
    //     frequency: currentZone.value.equalizer.frequencies[4],
    //   ),
    // );
    // final f1000 = await _readCommand(
    //   MultiroomCommandBuilder.getEqualizer(
    //     zone: currentZone.value,
    //     frequency: currentZone.value.equalizer.frequencies[5],
    //   ),
    // );
    // final f2000 = await _readCommand(
    //   MultiroomCommandBuilder.getEqualizer(
    //     zone: currentZone.value,
    //     frequency: currentZone.value.equalizer.frequencies[6],
    //   ),
    // );
    // final f4000 = await _readCommand(
    //   MultiroomCommandBuilder.getEqualizer(
    //     zone: currentZone.value,
    //     frequency: currentZone.value.equalizer.frequencies[7],
    //   ),
    // );
    // final f8000 = await _readCommand(
    //   MultiroomCommandBuilder.getEqualizer(
    //     zone: currentZone.value,
    //     frequency: currentZone.value.equalizer.frequencies[8],
    //   ),
    // );
    // final f16000 = await _readCommand(
    //   MultiroomCommandBuilder.getEqualizer(
    //     zone: currentZone.value,
    //     frequency: currentZone.value.equalizer.frequencies[9],
    //   ),
    // );

    _logger.d("""
      channel => $channel
      """);
    // volume => $volume
    // balance => $balance
    // f32 => $f32
    // f64 => $f64
    // f125 => $f125
    // f250 => $f250
    // f500 => $f500
    // f1000 => $f1000
    // f2000 => $f2000
    // f4000 => $f4000
    // f8000 => $f8000
    // f16000 => $f16000
  }

  Future<String> _listenOnIterator() async {
    while (await streamIterator.moveNext() == false) {
      await Future.delayed(Durations.short2);
    }

    final stringResponse = String.fromCharCodes(streamIterator.current);
    _logger.d("RECEIVED <<< $stringResponse");

    return stringResponse;
  }
}
