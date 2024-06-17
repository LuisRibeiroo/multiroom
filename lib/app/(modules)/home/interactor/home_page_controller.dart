import 'dart:async';

import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../../../../injector.dart';
import '../../../core/enums/mono_side.dart';
import '../../../core/enums/page_state.dart';
import '../../../core/interactor/controllers/base_controller.dart';
import '../../../core/interactor/controllers/socket_mixin.dart';
import '../../../core/interactor/repositories/settings_contract.dart';
import '../../../core/models/channel_model.dart';
import '../../../core/models/device_model.dart';
import '../../../core/models/equalizer_model.dart';
import '../../../core/models/frequency.dart';
import '../../../core/models/zone_model.dart';
import '../../../core/models/zone_wrapper_model.dart';
import '../../../core/utils/debouncer.dart';
import '../../../core/utils/mr_cmd_builder.dart';

class HomePageController extends BaseController with SocketMixin {
  HomePageController() : super(InitialState()) {
    localDevices.value = _settings.devices;
    currentDevice.value = localDevices.first;
    currentEqualizer.value = availableEqualizers.last;

    disposables.addAll([
      currentDevice.subscribe((value) async {
        if (value.isEmpty) {
          return;
        }

        if (value.serialNumber != currentDevice.previousValue!.serialNumber) {
          zones.value = value.zoneWrappers.fold([], (pv, v) => pv..addAll(v.zones));
          currentZone.value = zones.first;
        }

        if (currentDevice.previousValue != value) {
          logger.d("Save device --> ${value.serialNumber}");
          _settings.saveDevice(value);
        }
      }),
      currentZone.subscribe((newZone) async {
        if (newZone.isEmpty) {
          return;
        }

        channels.set(newZone.channels);
        currentDevice.value = currentDevice.value.copyWith(zones: _updateZone(newZone));

        untracked(() async {
          final idx = zones.value.indexWhere((zone) => currentZone.value.name == zone.name);
          zones.value[idx] = newZone;

          if (currentZone.previousValue!.id != currentZone.value.id) {
            logger.i("UPDATE ALL DATA");
            await _updateAllDeviceData();
          }
        });
      }),
    ]);
  }

  final _settings = injector.get<SettingsContract>();

  final localDevices = listSignal<DeviceModel>([], debugLabel: "device");
  final channels = listSignal<ChannelModel>([], debugLabel: "channels");
  final zones = listSignal<ZoneModel>([], debugLabel: "zones");
  final availableEqualizers = listSignal<EqualizerModel>(
    [
      EqualizerModel.builder(name: "Rock", v60: 20, v250: 0, v1k: 10, v3k: 20, v6k: 20, v16k: 10),
      EqualizerModel.builder(name: "Pop", v60: 20, v250: 10, v1k: 20, v3k: 30, v6k: 20, v16k: 20),
      EqualizerModel.builder(name: "Clássico", v60: 10, v250: 0, v1k: 10, v3k: 20, v6k: 10, v16k: 10),
      EqualizerModel.builder(name: "Jazz", v60: 10, v250: 0, v1k: 20, v3k: 30, v6k: 20, v16k: 10),
      EqualizerModel.builder(name: "Dance Music", v60: 40, v250: 20, v1k: 0, v3k: 30, v6k: 30, v16k: 20),
      EqualizerModel.builder(name: "Custom"),
    ],
    debugLabel: "availableEqualizers",
  );

  final currentDevice = DeviceModel.empty().toSignal(debugLabel: "device");
  final currentZone = ZoneModel.empty().toSignal(debugLabel: "currentZone");
  final currentChannel = ChannelModel.empty().toSignal(debugLabel: "currentChannel");
  final currentEqualizer = EqualizerModel.empty().toSignal(debugLabel: "currentEqualizer");

  final _writeDebouncer = Debouncer(delay: Durations.short4);

  void setCurrentDevice(DeviceModel device) {
    currentDevice.value = device;
  }

  void setCurrentZone(ZoneModel zone) {
    currentZone.value = zone;
  }

  void setCurrentChannel(ChannelModel channel) {
    if (channel.id == currentChannel.value.id) {
      logger.i("SET CHANNEL [SAME CHANNEL] --> ${channel.id}");
      return;
    }

    final channelIndex = channels.indexWhere((c) => c.name == channel.name);
    final tempList = List<ChannelModel>.from(channels);

    tempList[channelIndex] = channel;

    currentZone.value = currentZone.value.copyWith(channels: tempList);
    currentChannel.value = channel;

    socketSender(
      MrCmdBuilder.setChannel(
        zone: currentZone.value,
        channel: channel,
      ),
    );
  }

  void setBalance(int balance) {
    currentZone.value = currentZone.value.copyWith(balance: balance);

    debounceSendCommand(
      MrCmdBuilder.setBalance(
        zone: currentZone.value,
        balance: balance,
      ),
    );
  }

  void setVolume(int volume) {
    currentZone.value = currentZone.value.copyWith(volume: volume);

    debounceSendCommand(
      MrCmdBuilder.setVolume(
        zone: currentZone.value,
        volume: volume,
      ),
    );
  }

  Future<void> setEqualizer(EqualizerModel equalizer) async {
    if (equalizer == currentEqualizer.value) {
      logger.i("SET EQUALIZER [SAME EQUALIZER] --> $equalizer");
      return;
    }

    currentEqualizer.value = availableEqualizers.firstWhere((e) => e.name == equalizer.name);
    currentZone.value = currentZone.value.copyWith(equalizer: currentEqualizer.value);

    for (final freq in currentZone.value.equalizer.frequencies) {
      await socketSender(
        MrCmdBuilder.setEqualizer(
          zone: currentZone.value,
          frequency: freq,
          gain: freq.value,
        ),
      );

      // Delay to avoid sending commands too fast
      await Future.delayed(Durations.short2);
    }
  }

  void setFrequency(Frequency frequency) {
    final freqIndex = currentEqualizer.value.frequencies.indexWhere((f) => f.name == frequency.name);
    final tempList = List<Frequency>.from(currentEqualizer.value.frequencies);

    tempList[freqIndex] = currentEqualizer.value.frequencies[freqIndex].copyWith(value: frequency.value.toInt());

    currentEqualizer.value = EqualizerModel.custom(frequencies: tempList);
    currentZone.value = currentZone.value.copyWith(equalizer: currentEqualizer.value);

    debounceSendCommand(
      MrCmdBuilder.setEqualizer(
        zone: currentZone.value,
        frequency: frequency,
        gain: frequency.value,
      ),
    );
  }

  Future<void> debounceSendCommand(String cmd) async {
    _writeDebouncer(() async {
      try {
        await socketSender(cmd);
      } catch (exception) {
        setError(Exception("Erro no comando [$cmd] --> $exception"));
      }
    });
  }

  (Map, Map) _parseParams(Map<String, String> params) {
/*
  Params Response
  {SWM1L: (null), SWM1R: (null), SWM2L: (null), SWM2R: (null), SWM3L: (null), SWM3R: (null), SWM4L: (null), SWM4R: (null), SWM5L: (null), SWM5R: (null), SWM6L: (null), SWM6R: (null), SWM7L: (null), SWM7R: (null), SWM8L: (null), SWM8R: (null), SWS1: Z1, SWS2: Z1, SWS3: Z4, SWS4: Z4, SWS5: Z5, SWS6: Z6, SWS7: Z7, SWS8: Z8, VG1L: 47[%], VG1R: 47[%], VG2L: 100[%], VG2R: 100[%], VG3L: 50[%], VG3R: 50[%], VG4L: 100[%], VG4R: 100[%], VG5L: 100[%], VG5R: 100[%], VG6L: 100[%], VG6R: 100[%], VG7L: 100[%], VG7R: 100[%], VG8L: 100[%], VG8R: 100[%], EQ1L_32Hz: 80[0.1dB], EQ1R_32Hz: 80[0.1dB], EQ1L_64Hz: 60[0.1dB], EQ1R_64Hz: 60[0.1dB], EQ1L_125Hz: 60[0.1dB], EQ1R_125Hz: 60[0.1dB], EQ1L_250Hz: 60[0.1dB], EQ1R_250Hz: 60[0.1dB], EQ1L_500Hz: 60[0.1dB], EQ1R_500Hz: 60[0.1dB], EQ1L_1KHz: 60[0.1dB], EQ1R_1KHz: 60[0.1dB], EQ1L_2KHz: 60[0.1dB], EQ1R_2KHz: 60[0.1dB], EQ1L_4KHz: 60[0.1dB], EQ1R_4KHz: 60[0.1dB], EQ1L_8KHz: 60[0.1dB], EQ1R_8KHz: 60[0.1dB], EQ1L_16KHz: 60[0.1dB], EQ1R_16KHz: 60[0.1dB], EQ2L_32Hz: 1[0.1dB], EQ2R_32Hz: 1[0.1dB], EQ2L_64Hz: 1[0.1dB], EQ2R_64Hz: 1[0.1dB], EQ2L_125Hz: 1[0.1dB], EQ2R_125Hz: 1[0.1dB], EQ2L_250Hz: 1[0.1dB], EQ2R_250Hz: 1[0.1dB], EQ2L_500Hz: 1[0.1dB], EQ2R_500Hz: 1[0.1dB], EQ2L_1KHz: 1[0.1dB], EQ2R_1KHz: 1[0.1dB], EQ2L_2KHz: 1[0.1dB], EQ2R_2KHz: 1[0.1dB], EQ2L_4KHz: 1[0.1dB], EQ2R_4KHz: 1[0.1dB], EQ2L_8KHz: 1[0.1dB], EQ2R_8KHz: 1[0.1dB], EQ2L_16KHz: 1[0.1dB], EQ2R_16KHz: 1[0.1dB], EQ3L_32Hz: 1[0.1dB], EQ3R_32Hz: 1[0.1dB], EQ3L_64Hz: 1[0.1dB], EQ3R_64Hz: 1[0.1dB], EQ3L_125Hz: 1[0.1dB], EQ3R_125Hz: 1[0.1dB], EQ3L_250Hz: 1[0.1dB], EQ3R_250Hz: 1[0.1dB], EQ3L_500Hz: 1[0.1dB], EQ3R_500Hz: 1[0.1dB], EQ3L_1KHz: 1[0.1dB], EQ3R_1KHz: 1[0.1dB], EQ3L_2KHz: 1[0.1dB], EQ3R_2KHz: 1[0.1dB], EQ3L_4KHz: 1[0.1dB], EQ3R_4KHz: 1[0.1dB], EQ3L_8KHz: 1[0.1dB], EQ3R_8KHz: 1[0.1dB], EQ3L_16KHz: 1[0.1dB], EQ3R_16KHz: 1[0.1dB], EQ4L_32Hz: 0[0.1dB], EQ4R_32Hz: 0[0.1dB], EQ4L_64Hz: 0[0.1dB], EQ4R_64Hz: 0[0.1dB], EQ4L_125Hz: 0[0.1dB], EQ4R_125Hz: 0[0.1dB], EQ4L_250Hz: 0[0.1dB], EQ4R_250Hz: 0[0.1dB], EQ4L_500Hz: 0[0.1dB], EQ4R_500Hz: 0[0.1dB], EQ4L_1KHz: 0[0.1dB], EQ4R_1KHz: 0[0.1dB], EQ4L_2KHz: 0[0.1dB], EQ4R_2KHz: 0[0.1dB], EQ4L_4KHz: 0[0.1dB], EQ4R_4KHz: 0[0.1dB], EQ4L_8KHz: 0[0.1dB], EQ4R_8KHz: 0[0.1dB], EQ4L_16KHz: 0[0.1dB], EQ4R_16KHz: 0[0.1dB], EQ5L_32Hz: 0[0.1dB], EQ5R_32Hz: 0[0.1dB], EQ5L_64Hz: 0[0.1dB], EQ5R_64Hz: 0[0.1dB], EQ5L_125Hz: 0[0.1dB], EQ5R_125Hz: 0[0.1dB], EQ5L_250Hz: 0[0.1dB], EQ5R_250Hz: 0[0.1dB], EQ5L_500Hz: 0[0.1dB], EQ5R_500Hz: 0[0.1dB], EQ5L_1KHz: 0[0.1dB], EQ5R_1KHz: 0[0.1dB], EQ5L_2KHz: 0[0.1dB], EQ5R_2KHz: 0[0.1dB], EQ5L_4KHz: 0[0.1dB], EQ5R_4KHz: 0[0.1dB], EQ5L_8KHz: 0[0.1dB], EQ5R_8KHz: 0[0.1dB], EQ5L_16KHz: 0[0.1dB], EQ5R_16KHz: 0[0.1dB], EQ6L_32Hz: 0[0.1dB], EQ6R_32Hz: 0[0.1dB], EQ6L_64Hz: 0[0.1dB], EQ6R_64Hz: 0[0.1dB], EQ6L_125Hz: 0[0.1dB], EQ6R_125Hz: 0[0.1dB], EQ6L_250Hz: 0[0.1dB], EQ6R_250Hz: 0[0.1dB], EQ6L_500Hz: 0[0.1dB], EQ6R_500Hz: 0[0.1dB], EQ6L_1KHz: 0[0.1dB], EQ6R_1KHz: 0[0.1dB], EQ6L_2KHz: 0[0.1dB], EQ6R_2KHz: 0[0.1dB], EQ6L_4KHz: 0[0.1dB], EQ6R_4KHz: 0[0.1dB], EQ6L_8KHz: 0[0.1dB], EQ6R_8KHz: 0[0.1dB], EQ6L_16KHz: 0[0.1dB], EQ6R_16KHz: 0[0.1dB], EQ7L_32Hz: 0[0.1dB], EQ7R_32Hz: 0[0.1dB], EQ7L_64Hz: 0[0.1dB], EQ7R_64Hz: 0[0.1dB], EQ7L_125Hz: 0[0.1dB], EQ7R_125Hz: 0[0.1dB], EQ7L_250Hz: 0[0.1dB], EQ7R_250Hz: 0[0.1dB], EQ7L_500Hz: 0[0.1dB], EQ7R_500Hz: 0[0.1dB], EQ7L_1KHz: 0[0.1dB], EQ7R_1KHz: 0[0.1dB], EQ7L_2KHz: 0[0.1dB], EQ7R_2KHz: 0[0.1dB], EQ7L_4KHz: 0[0.1dB], EQ7R_4KHz: 0[0.1dB], EQ7L_8KHz: 0[0.1dB], EQ7R_8KHz: 0[0.1dB], EQ7L_16KHz: 0[0.1dB], EQ7R_16KHz: 0[0.1dB], EQ8L_32Hz: 0[0.1dB], EQ8R_32Hz: 0[0.1dB], EQ8L_64Hz: 0[0.1dB], EQ8R_64Hz: 0[0.1dB], EQ8L_125Hz: 0[0.1dB], EQ8R_125Hz: 0[0.1dB], EQ8L_250Hz: 0[0.1dB], EQ8R_250Hz: 0[0.1dB], EQ8L_500Hz: 0[0.1dB], EQ8R_500Hz: 0[0.1dB], EQ8L_1KHz: 0[0.1dB], EQ8R_1KHz: 0[0.1dB], EQ8L_2KHz: 0[0.1dB], EQ8R_2KHz: 0[0.1dB], EQ8L_4KHz: 0[0.1dB], EQ8R_4KHz: 0[0.1dB], EQ8L_8KHz: 0[0.1dB], EQ8R_8KHz: 0[0.1dB], EQ8L_16KHz: 0[0.1dB], EQ8R_16KHz: 0[0.1dB], PWR1L: ON, PWR1R: ON, PWR2L: ON, PWR2R: ON, PWR3L: ON, PWR3R: ON, PWR4L: ON, PWR4R: ON, PWR5L: ON, PWR5R: ON, PWR6L: ON, PWR6R: ON, PWR7L: ON, PWR7R: ON, PWR8L: ON, PWR8R: ON}
*/
    final stereoParams = <String, String>{};
    final monoParams = <String, String>{};

    // final allChannels = params.entries.where((entry) => entry.key.toUpperCase().startsWith("SW"));
    // final channel = allChannels.firstWhere((ch) => ch.key.endsWith(currentZone.value.id.replaceAll("Z", ""))).value;
    // logger.d(channel);

    for (final entry in params.entries) {
      if (entry.key.contains(RegExp("([1-8][L])")) || entry.key.contains(RegExp("([1-8][R])"))) {
        monoParams[entry.key] = entry.value;
      } else {
        stereoParams[entry.key] = entry.value;
      }
    }

    logger.d("MONO --> $monoParams");
    logger.d("STEREO --> $stereoParams");

    return (stereoParams, monoParams);
  }

  List<ZoneWrapperModel> _updateZone(ZoneModel zone) {
    List<ZoneWrapperModel> newZones = List.from(currentDevice.peek().zoneWrappers);
    int idx = -1;

    for (final wrapper in newZones) {
      final tempZ = wrapper.zones.firstWhere(
        (z) => z.id == zone.id,
        orElse: () => ZoneModel.empty(),
      );

      if (tempZ.isEmpty) {
        continue;
      }

      idx = newZones.indexOf(wrapper);
      break;
    }

    if (idx == -1) {
      throw Exception("Zone not found ${zone.id}");
    }

    ZoneWrapperModel newWrapper = newZones[idx];

    if (newWrapper.isStereo) {
      newWrapper = newWrapper.copyWith(stereoZone: zone);
    } else {
      if (zone.side == MonoSide.left) {
        newWrapper = newWrapper.copyWith(monoZones: (left: zone, right: newWrapper.monoZones.right));
      } else {
        newWrapper = newWrapper.copyWith(monoZones: (right: zone, left: newWrapper.monoZones.left));
      }
    }

    newZones[idx] = newWrapper;

    return newZones;
  }

  Future<void> _updateAllDeviceData() async {
    // final params = await socketSender(
    //   MrCmdBuilder.params,
    //   longRet: true,
    // );
    // final (stereoParams, monoParams) = _parseChannels(params);

    // final (stereoParams, monoParams) = _parseParams(jsonData);

    // final currentWrappers = device.value.zoneWrappers;
    // currentWrappers.first.copyWith(
    //   stereoZone: currentWrappers.first.stereoZone.copyWith(),
    // );

    // for (final param in stereoParams.entries) {}

    // device.value = device.value.copyWith(zones: []);

    final channelStr = await socketSender(
      MrCmdBuilder.getChannel(zone: currentZone.value),
    );

    final volume = await socketSender(
      MrCmdBuilder.getVolume(zone: currentZone.value),
    );

    final balance = await socketSender(
      MrCmdBuilder.getBalance(zone: currentZone.value),
    );

    final f60 = await socketSender(
      MrCmdBuilder.getEqualizer(
        zone: currentZone.value,
        frequency: currentZone.value.equalizer.frequencies[0],
      ),
    );

    final f1k = await socketSender(
      MrCmdBuilder.getEqualizer(
        zone: currentZone.value,
        frequency: currentZone.value.equalizer.frequencies[1],
      ),
    );

    final f3k = await socketSender(
      MrCmdBuilder.getEqualizer(
        zone: currentZone.value,
        frequency: currentZone.value.equalizer.frequencies[2],
      ),
    );

    final f250 = await socketSender(
      MrCmdBuilder.getEqualizer(
        zone: currentZone.value,
        frequency: currentZone.value.equalizer.frequencies[3],
      ),
    );

    final f6k = await socketSender(
      MrCmdBuilder.getEqualizer(
        zone: currentZone.value,
        frequency: currentZone.value.equalizer.frequencies[4],
      ),
    );

    final f16k = await socketSender(
      MrCmdBuilder.getEqualizer(
        zone: currentZone.value,
        frequency: currentZone.value.equalizer.frequencies[5],
      ),
    );

    currentChannel.value = channels.value.firstWhere(
      (c) => c.id.trim() == channelStr.trim(),
      orElse: () => currentChannel.value,
    );

    final equalizer = currentZone.value.equalizer;
    final newEqualizer = EqualizerModel.custom(
      frequencies: [
        equalizer.frequencies[0].copyWith(value: int.tryParse(f60) ?? equalizer.frequencies[0].value),
        equalizer.frequencies[1].copyWith(value: int.tryParse(f250) ?? equalizer.frequencies[1].value),
        equalizer.frequencies[2].copyWith(value: int.tryParse(f1k) ?? equalizer.frequencies[2].value),
        equalizer.frequencies[3].copyWith(value: int.tryParse(f3k) ?? equalizer.frequencies[3].value),
        equalizer.frequencies[4].copyWith(value: int.tryParse(f6k) ?? equalizer.frequencies[4].value),
        equalizer.frequencies[5].copyWith(value: int.tryParse(f16k) ?? equalizer.frequencies[5].value),
      ],
    );

    final f = availableEqualizers.indexWhere((e) => e.equalsFrequencies(newEqualizer));
    if (f == -1) {
      availableEqualizers[availableEqualizers.indexWhere((e) => e.name == "Custom")] = newEqualizer;
      currentEqualizer.value = newEqualizer;
    } else {
      currentEqualizer.value = availableEqualizers[f];
    }

    untracked(() {
      currentZone.value = currentZone.value.copyWith(
        volume: int.tryParse(volume) ?? currentZone.value.volume,
        balance: int.tryParse(balance) ?? currentZone.value.balance,
        equalizer: newEqualizer,
      );
    });
  }

  @override
  void dispose() {
    super.dispose();

    localDevices.value = <DeviceModel>[];
    zones.value = <ZoneModel>[];
    currentDevice.value = currentDevice.initialValue;
    currentZone.value = currentZone.initialValue;
    currentChannel.value = currentChannel.initialValue;
    currentEqualizer.value = currentEqualizer.initialValue;
  }
}
