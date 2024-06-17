import 'dart:async';

import 'package:flutter/material.dart';
import 'package:multiroom/routes.g.dart';
import 'package:routefly/routefly.dart';
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
      effect(() {
        if (localDevices.isEmpty) {
          Routefly.replace(routePaths.configs.pages.configs);
          Routefly.pushNavigate(routePaths.configs.pages.configs);
        } else {
          currentDevice.value = localDevices.first;
        }
      }),
      currentDevice.subscribe((value) async {
        if (value.isEmpty) {
          return;
        }

        if (value.serialNumber != currentDevice.previousValue!.serialNumber) {
          zones.value = value.zones;
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
        currentDevice.value = currentDevice.value.copyWith(zoneWrappers: _getUpdatedZones(newZone));

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

  Future<void> init() async {
    try {
      await initSocket(ip: currentDevice.value.ip);
    } catch (exception) {
      setError(exception as Exception);
    }
  }

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
    final freqIndex = currentEqualizer.value.frequencies.indexWhere((f) => f.id == frequency.id);
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

  void syncLocalDevices() {
    localDevices.value = _settings.devices;
  }

  Future<void> _debounceSendCommand(String cmd) async {
    _writeDebouncer(() async {
      try {
        await socketSender(cmd);
      } catch (exception) {
        setError(Exception("Erro no comando [$cmd] --> $exception"));
      }
    });
  }

  List<ZoneWrapperModel> _getUpdatedZones(ZoneModel zone) {
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
    while (socketInit == false) {
      await Future.delayed(Durations.short3);
    }

    final channelStr = MrCmdBuilder.parseResponse(await socketSender(
      MrCmdBuilder.getChannel(zone: currentZone.value),
    ));

    final volume = MrCmdBuilder.parseResponse(await socketSender(
      MrCmdBuilder.getVolume(zone: currentZone.value),
    ));

    String balance = "0";
    if (currentZone.value.isStereo) {
      balance = MrCmdBuilder.parseResponse(await socketSender(
        MrCmdBuilder.getBalance(zone: currentZone.value),
      ));
    }

    final f60 = MrCmdBuilder.parseResponse(await socketSender(
      MrCmdBuilder.getEqualizer(
        zone: currentZone.value,
        frequency: currentZone.value.equalizer.frequencies[0],
      ),
    ));

    final f1k = MrCmdBuilder.parseResponse(await socketSender(
      MrCmdBuilder.getEqualizer(
        zone: currentZone.value,
        frequency: currentZone.value.equalizer.frequencies[1],
      ),
    ));

    final f3k = MrCmdBuilder.parseResponse(await socketSender(
      MrCmdBuilder.getEqualizer(
        zone: currentZone.value,
        frequency: currentZone.value.equalizer.frequencies[2],
      ),
    ));

    final f250 = MrCmdBuilder.parseResponse(await socketSender(
      MrCmdBuilder.getEqualizer(
        zone: currentZone.value,
        frequency: currentZone.value.equalizer.frequencies[3],
      ),
    ));

    final f6k = MrCmdBuilder.parseResponse(await socketSender(
      MrCmdBuilder.getEqualizer(
        zone: currentZone.value,
        frequency: currentZone.value.equalizer.frequencies[4],
      ),
    ));

    final f16k = MrCmdBuilder.parseResponse(await socketSender(
      MrCmdBuilder.getEqualizer(
        zone: currentZone.value,
        frequency: currentZone.value.equalizer.frequencies[5],
      ),
    ));

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
    mixinDispose();

    localDevices.value = <DeviceModel>[];
    zones.value = <ZoneModel>[];
    currentDevice.value = currentDevice.initialValue;
    currentZone.value = currentZone.initialValue;
    currentChannel.value = currentChannel.initialValue;
    currentEqualizer.value = currentEqualizer.initialValue;
  }
}
