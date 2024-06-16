import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:signals/signals_flutter.dart';
import 'package:toastification/toastification.dart';
import 'package:udp/udp.dart';

import '../../core/enums/page_state.dart';
import '../../core/extensions/string_extensions.dart';
import '../../core/interactor/controllers/base_controller.dart';
import '../../core/models/channel_model.dart';
import '../../core/models/equalizer_model.dart';
import '../../core/models/frequency.dart';
import '../../core/models/zone_model.dart';
import '../../core/utils/debouncer.dart';
import '../../core/models/device_model.dart';
import '../../core/utils/mr_cmd_builder.dart';

class HomePageController extends BaseController {
  HomePageController() : super(InitialState()) {
    _initUdp();

    currentEqualizer.value = equalizers.last;

    device.subscribe((value) async {
      if (value.isEmpty) {
        return;
      }

      // currentZone.value = value.zones.first;
    });

    currentZone.subscribe((newZone) async {
      if (newZone.isEmpty) {
        return;
      }

      // final idx = device.value.zones.indexWhere((zone) => currentZone.value.name == zone.name);
      // channels.set(newZone.channels);

      // untracked(() async {
      //   device.value.zones[idx] = newZone;

      //   if (currentZone.previousValue!.id != currentZone.value.id) {
      //     _logger.i("UPDATE ALL DATA");
      //     await run(_updateAllDeviceData);
      //   }
      // });
    });

    channels.subscribe((newValue) {
      untracked(() {
        channelController.setOptions(
          List.generate(
            newValue.length,
            (idx) => ValueItem(
              label: newValue[idx].name,
              value: idx,
            ),
          ),
        );
      });
    });

    equalizers.subscribe((newValue) {
      untracked(() {
        equalizerController.setOptions(
          List.generate(
            newValue.length,
            (idx) => ValueItem(
              label: newValue[idx].name,
              value: idx,
            ),
          ),
        );
      });
    });

    currentChannel.subscribe((channel) {
      if (channel.isEmpty) {
        return;
      }

      untracked(() {
        final id = int.parse(channel.id.numbersOnly);

        channelController.setSelectedOptions(
          [
            channelController.options.firstWhere(
              (opt) => opt.value == id - 1,
              orElse: () => channelController.options.first,
            ),
          ],
        );
      });
    });

    currentEqualizer.subscribe((equalizer) {
      if (equalizer.isEmpty /* || equalizer.name == currentEqualizer.value.name */) {
        return;
      }

      untracked(() {
        equalizerController.setSelectedOptions(
          [
            equalizerController.options.firstWhere(
              (opt) => opt.label == equalizer.name,
              orElse: () => equalizerController.options.firstWhere(
                (e) => e.label == "Custom",
                orElse: () => equalizerController.options.first,
              ),
            ),
          ],
        );
      });
    });
  }

  late UDP udpServer;
  late Socket _socket;

  final equalizers = listSignal<EqualizerModel>(
    [
      EqualizerModel.builder(name: "Rock", v60: 2, v250: 0, v1k: 1, v3k: 2, v6k: 2, v16k: 1),
      EqualizerModel.builder(name: "Pop", v60: 2, v250: 1, v1k: 2, v3k: 3, v6k: 2, v16k: 2),
      EqualizerModel.builder(name: "Clássico", v60: 1, v250: 0, v1k: 1, v3k: 2, v6k: 1, v16k: 1),
      EqualizerModel.builder(name: "Jazz", v60: 1, v250: 0, v1k: 2, v3k: 3, v6k: 2, v16k: 1),
      EqualizerModel.builder(name: "Dance Music", v60: 4, v250: 2, v1k: 0, v3k: 3, v6k: 3, v16k: 2),
      EqualizerModel.builder(name: "Custom"),
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

  final host = "192.168.0.22".toSignal(debugLabel: "host");
  final port = "4998".toSignal(debugLabel: "port");
  final isConnected = false.toSignal(debugLabel: "isConnected");
  final isServerListening = false.toSignal(debugLabel: "isServerListening");
  final device = DeviceModel.empty().toSignal(debugLabel: "device");
  final currentZone = ZoneModel.empty().toSignal(debugLabel: "currentZone");
  final currentChannel = ChannelModel.empty().toSignal(debugLabel: "currentChannel");
  final currentEqualizer = EqualizerModel.empty().toSignal(debugLabel: "currentEqualizer");

  final _writeDebouncer = Debouncer(delay: Durations.short4);
  late StreamIterator<Uint8List> streamIterator;
  final channelController = MultiSelectController<int>();
  final equalizerController = MultiSelectController<int>();

  Future<void> _initUdp() async {
    final localip = await NetworkInfo().getWifiIP();

    // host.value = localip ?? "";
    _logger.i("LOCAL IP --> $localip");

    udpServer = await UDP.bind(
      Endpoint.unicast(
        InternetAddress.anyIPv4,
        port: const Port(4055),
      ),
    );

    effect(() {
      if (isServerListening.value) {
        _logger.i("UDP LISTENING ON --> ${udpServer.local.address?.address}:${udpServer.local.port?.value} ");
      } else {
        _logger.i("UDP SERVER CLOSED");
      }
    });
  }

  Future<void> test() async {
    _readCommand(MrCmdBuilder.getZoneMode(zone: currentZone.value));
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
          serialNumber: "",
          name: "Master 1",
          ip: host.value,
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

          _logger.i("UDP DATA --> $data | FROM ${datagram.address.address}:${datagram.port}");

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
    if (channel.id == currentChannel.value.id) {
      _logger.i("SET CHANNEL [SAME CHANNEL] --> ${channel.id}");
      return;
    }

    final channelIndex = channels.indexWhere((c) => c.name == channel.name);
    final tempList = List<ChannelModel>.from(channels);

    tempList[channelIndex] = channel;

    currentZone.value = currentZone.value.copyWith(channels: tempList);
    currentChannel.value = channel;

    _debounceSendCommand(
      MrCmdBuilder.setChannel(
        zone: currentZone.value,
        channel: channel,
      ),
    );
  }

  void setBalance(int balance) {
    currentZone.value = currentZone.value.copyWith(balance: balance);

    _debounceSendCommand(
      MrCmdBuilder.setBalance(
        zone: currentZone.value,
        balance: balance,
      ),
    );
  }

  void setVolume(int volume) {
    currentZone.value = currentZone.value.copyWith(volume: volume);

    _debounceSendCommand(
      MrCmdBuilder.setVolume(
        zone: currentZone.value,
        volume: volume,
      ),
    );
  }

  Future<void> setEqualizer(String equalizerName) async {
    if (equalizerName == currentEqualizer.value.name) {
      _logger.i("SET EQUALIZER [SAME EQUALIZER] --> $equalizerName");
      return;
    }

    currentEqualizer.value = equalizers.firstWhere((e) => e.name == equalizerName);
    currentZone.value = currentZone.value.copyWith(equalizer: currentEqualizer.value);

    for (final freq in currentZone.value.equalizer.frequencies) {
      _debounceSendCommand(
        MrCmdBuilder.setEqualizer(
          zone: currentZone.value,
          frequency: freq,
          gain: freq.value,
        ),
      );

      // Delay to avoid sending commands too fast
      await _delayBetweenCmd();
    }
  }

  void setFrequency(Frequency frequency) {
    final freqIndex = currentEqualizer.value.frequencies.indexWhere((f) => f.name == frequency.name);
    final tempList = List<Frequency>.from(currentEqualizer.value.frequencies);

    tempList[freqIndex] = currentEqualizer.value.frequencies[freqIndex].copyWith(value: frequency.value.toInt());

    currentEqualizer.value = EqualizerModel.custom(frequencies: tempList);
    currentZone.value = currentZone.value.copyWith(equalizer: currentEqualizer.value);

    _debounceSendCommand(
      MrCmdBuilder.setEqualizer(
        zone: currentZone.value,
        frequency: frequency,
        gain: frequency.value,
      ),
    );
  }

  Future<void> _debounceSendCommand(String cmd) async {
    _writeDebouncer(() async {
      _socket.writeln(cmd);
      _logger.i(">>> $cmd");

      try {
        await _listenOnIterator();
      } catch (exception) {
        setError(Exception("Erro no comando [$cmd] --> $exception"));
      }
    });
  }

  Future<String> _readCommand(String cmd) async {
    _socket.writeln(cmd);
    _logger.i(">>> $cmd");

    return await _listenOnIterator();
  }

  Future<void> _updateAllDeviceData() async {
    final channelStr = await _readCommand(MrCmdBuilder.getChannel(zone: currentZone.value));
    await _delayBetweenCmd();

    final volume = await _readCommand(MrCmdBuilder.getVolume(zone: currentZone.value));
    await _delayBetweenCmd();

    final balance = await _readCommand(MrCmdBuilder.getBalance(zone: currentZone.value));
    await _delayBetweenCmd();

    final f32 = await _readCommand(
      MrCmdBuilder.getEqualizer(
        zone: currentZone.value,
        frequency: currentZone.value.equalizer.frequencies[0],
      ),
    );
    await _delayBetweenCmd();

    final f64 = await _readCommand(
      MrCmdBuilder.getEqualizer(
        zone: currentZone.value,
        frequency: currentZone.value.equalizer.frequencies[1],
      ),
    );
    await _delayBetweenCmd();

    final f125 = await _readCommand(
      MrCmdBuilder.getEqualizer(
        zone: currentZone.value,
        frequency: currentZone.value.equalizer.frequencies[2],
      ),
    );
    await _delayBetweenCmd();

    final f250 = await _readCommand(
      MrCmdBuilder.getEqualizer(
        zone: currentZone.value,
        frequency: currentZone.value.equalizer.frequencies[3],
      ),
    );
    await _delayBetweenCmd();

    final f500 = await _readCommand(
      MrCmdBuilder.getEqualizer(
        zone: currentZone.value,
        frequency: currentZone.value.equalizer.frequencies[4],
      ),
    );
    await _delayBetweenCmd();

    final f1000 = await _readCommand(
      MrCmdBuilder.getEqualizer(
        zone: currentZone.value,
        frequency: currentZone.value.equalizer.frequencies[5],
      ),
    );
    await _delayBetweenCmd();

    final f2000 = await _readCommand(
      MrCmdBuilder.getEqualizer(
        zone: currentZone.value,
        frequency: currentZone.value.equalizer.frequencies[6],
      ),
    );
    await _delayBetweenCmd();

    final f4000 = await _readCommand(
      MrCmdBuilder.getEqualizer(
        zone: currentZone.value,
        frequency: currentZone.value.equalizer.frequencies[7],
      ),
    );
    await _delayBetweenCmd();

    final f8000 = await _readCommand(
      MrCmdBuilder.getEqualizer(
        zone: currentZone.value,
        frequency: currentZone.value.equalizer.frequencies[8],
      ),
    );
    await _delayBetweenCmd();

    final f16000 = await _readCommand(
      MrCmdBuilder.getEqualizer(
        zone: currentZone.value,
        frequency: currentZone.value.equalizer.frequencies[9],
      ),
    );

    currentChannel.value = channels.value.firstWhere(
      (c) => c.id.trim() == channelStr.trim(),
      orElse: () => currentChannel.value.copyWith(name: channelStr),
    );

    final equalizer = currentZone.value.equalizer;
    final newEqualizer = EqualizerModel.custom(
      frequencies: [
        equalizer.frequencies[0].copyWith(value: int.tryParse(f32) ?? equalizer.frequencies[0].value),
        equalizer.frequencies[1].copyWith(value: int.tryParse(f64) ?? equalizer.frequencies[1].value),
        equalizer.frequencies[2].copyWith(value: int.tryParse(f125) ?? equalizer.frequencies[2].value),
        equalizer.frequencies[3].copyWith(value: int.tryParse(f250) ?? equalizer.frequencies[3].value),
        equalizer.frequencies[4].copyWith(value: int.tryParse(f500) ?? equalizer.frequencies[4].value),
        equalizer.frequencies[5].copyWith(value: int.tryParse(f1000) ?? equalizer.frequencies[5].value),
        equalizer.frequencies[6].copyWith(value: int.tryParse(f2000) ?? equalizer.frequencies[6].value),
        equalizer.frequencies[7].copyWith(value: int.tryParse(f4000) ?? equalizer.frequencies[7].value),
        equalizer.frequencies[8].copyWith(value: int.tryParse(f8000) ?? equalizer.frequencies[8].value),
        equalizer.frequencies[9].copyWith(value: int.tryParse(f16000) ?? equalizer.frequencies[9].value),
      ],
    );

    equalizers[equalizers.indexWhere((e) => e.name == currentEqualizer.value.name)] = newEqualizer;
    currentEqualizer.value = newEqualizer;

    currentZone.value = currentZone.value.copyWith(
      volume: int.tryParse(volume) ?? currentZone.value.volume,
      balance: int.tryParse(balance) ?? currentZone.value.balance,
      equalizer: newEqualizer,
    );
  }

  Future<String> _listenOnIterator() async {
    try {
      while (await streamIterator.moveNext() == false) {
        await Future.delayed(Durations.short1);
      }

      final response = String.fromCharCodes(streamIterator.current);
      _logger.i("<<< $response");

      return MrCmdBuilder.parseResponse(response);
    } catch (exception) {
      throw Exception("Erro ao ler resposta [$exception]");
    }
  }

  Future<void> _delayBetweenCmd() => Future.delayed(Duration.zero);
}
