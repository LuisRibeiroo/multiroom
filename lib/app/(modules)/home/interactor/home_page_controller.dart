import 'dart:async';

import 'package:flutter/material.dart';
import 'package:routefly/routefly.dart';
import 'package:signals/signals_flutter.dart';

import '../../../../injector.dart';
import '../../../../routes.g.dart';
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
    currentEqualizer.value = equalizers.last;

    disposables.addAll([
      effect(() {
        if (localDevices.isEmpty) {
          Routefly.replace(routePaths.configs.pages.configs);
          Routefly.pushNavigate(routePaths.configs.pages.configs);
        }
      }),
      currentDevice.subscribe((value) async {
        if (value.isEmpty) {
          return;
        }

        if (value.serialNumber != currentDevice.previousValue!.serialNumber) {
          zones.value = value.zones;
          channels.value = value.zones.first.channels;
        }

        if (currentDevice.previousValue != value) {
          logger.d("Save device --> ${value.serialNumber}");
          _settings.saveDevice(value);
        }
      }),
    ]);
  }

  final _settings = injector.get<SettingsContract>();

  final localDevices = listSignal<DeviceModel>([], debugLabel: "localDevices");
  final channels = listSignal<ChannelModel>([], debugLabel: "channels");
  final zones = listSignal<ZoneModel>([], debugLabel: "zones");
  final equalizers = listSignal<EqualizerModel>(
    [
      EqualizerModel.builder(name: "Rock", v60: 2, v250: 0, v1k: 1, v3k: 2, v6k: 2, v16k: 1),
      EqualizerModel.builder(name: "Pop", v60: 2, v250: 1, v1k: 2, v3k: 3, v6k: 2, v16k: 2),
      EqualizerModel.builder(name: "Clássico", v60: 1, v250: 0, v1k: 1, v3k: 2, v6k: 1, v16k: 1),
      EqualizerModel.builder(name: "Jazz", v60: 1, v250: 0, v1k: 2, v3k: 3, v6k: 2, v16k: 1),
      EqualizerModel.builder(name: "Dance Music", v60: 4, v250: 2, v1k: 0, v3k: 3, v6k: 3, v16k: 2),
      EqualizerModel.builder(name: "Flat", v60: 0, v250: 0, v1k: 0, v3k: 0, v6k: 0, v16k: 0),
      EqualizerModel.builder(name: "Custom"),
    ],
    debugLabel: "equalizers",
  );

  final currentDevice = DeviceModel.empty().toSignal(debugLabel: "currentDevice");
  final currentZone = ZoneModel.empty().toSignal(debugLabel: "currentZone");
  final currentChannel = ChannelModel.empty().toSignal(debugLabel: "currentChannel");
  final currentEqualizer = EqualizerModel.empty().toSignal(debugLabel: "currentEqualizer");

  final _writeDebouncer = Debouncer(delay: Durations.short4);

  Future<void> init() async {
    try {
      // await initSocket(ip: currentDevice.value.ip);
    } catch (exception) {
      setError(exception as Exception);
    }
  }

  Future<void> setCurrentDeviceAndZone(DeviceModel device, ZoneModel zone) async {
    channels.set(zone.channels);

    if (device.serialNumber != currentDevice.value.serialNumber) {
      currentDevice.value = device;
    }

    if (currentDevice.previousValue!.serialNumber != currentDevice.value.serialNumber ||
        currentZone.value.id != zone.id) {
      logger.i("UPDATE ALL DATA");
      await _updateAllDeviceData(zone);
    }
  }

  Future<void> setZoneActive(bool active) async {
    currentZone.value = currentZone.value.copyWith(active: active);

    _debounceSendCommand(
      MrCmdBuilder.setPower(
        zone: currentZone.value,
        active: active,
      ),
    );
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

  Future<void> setEqualizer(EqualizerModel equalizer) async {
    if (equalizer == currentEqualizer.value) {
      logger.i("SET EQUALIZER [SAME EQUALIZER] --> $equalizer");
      return;
    }

    currentEqualizer.value = equalizers.firstWhere((e) => e.name == equalizer.name);
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

  Future<void> syncLocalDevices() async {
    await run(() {
      localDevices.value = _settings.devices;

      disposables.addAll(
        [
          untracked(() {
            if (localDevices.isEmpty) {
              return;
            }

            currentDevice.value = localDevices.value.first;
            zones.value = currentDevice.value.zones;

            if (currentDevice.value.isZoneInGroup(zones.first)) {
              currentZone.value = currentDevice.value.groups.firstWhere((g) => g.zones.contains(zones.first)).asZone;
            } else {
              currentZone.value = zones.first;
            }

            return null;
          }),
        ],
      );
    });
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

  Future<void> _updateAllDeviceData(ZoneModel zone) async {
    // while (socketInit == false) {
    //   await Future.delayed(Durations.short3);
    // }

    final active = MrCmdBuilder.parseResponse(await socketSender(
      MrCmdBuilder.getPower(zone: zone),
    ));

    final channelStr = MrCmdBuilder.parseResponse(await socketSender(
      MrCmdBuilder.getChannel(zone: zone),
    ));

    final volume = MrCmdBuilder.parseResponse(await socketSender(
      MrCmdBuilder.getVolume(zone: zone),
    ));

    String balance = "0";
    if (zone.isStereo) {
      balance = MrCmdBuilder.parseResponse(await socketSender(
        MrCmdBuilder.getBalance(zone: zone),
      ));
    }

    final f60 = MrCmdBuilder.parseResponse(await socketSender(
      MrCmdBuilder.getEqualizer(
        zone: zone,
        frequency: zone.equalizer.frequencies[0],
      ),
    ));

    final f1k = MrCmdBuilder.parseResponse(await socketSender(
      MrCmdBuilder.getEqualizer(
        zone: zone,
        frequency: zone.equalizer.frequencies[1],
      ),
    ));

    final f3k = MrCmdBuilder.parseResponse(await socketSender(
      MrCmdBuilder.getEqualizer(
        zone: zone,
        frequency: zone.equalizer.frequencies[2],
      ),
    ));

    final f250 = MrCmdBuilder.parseResponse(await socketSender(
      MrCmdBuilder.getEqualizer(
        zone: zone,
        frequency: zone.equalizer.frequencies[3],
      ),
    ));

    final f6k = MrCmdBuilder.parseResponse(await socketSender(
      MrCmdBuilder.getEqualizer(
        zone: zone,
        frequency: zone.equalizer.frequencies[4],
      ),
    ));

    final f16k = MrCmdBuilder.parseResponse(await socketSender(
      MrCmdBuilder.getEqualizer(
        zone: zone,
        frequency: zone.equalizer.frequencies[5],
      ),
    ));

    currentChannel.value = channels.value.firstWhere(
      (c) => c.id.trim() == channelStr.trim(),
      orElse: () => currentChannel.value,
    );

    final equalizer = zone.equalizer;
    final newEqualizer = EqualizerModel.custom(
      frequencies: [
        equalizer.frequencies[0].copyWith(value: (int.tryParse(f60) ?? equalizer.frequencies[0].value) ~/ 10),
        equalizer.frequencies[1].copyWith(value: (int.tryParse(f250) ?? equalizer.frequencies[1].value) ~/ 10),
        equalizer.frequencies[2].copyWith(value: (int.tryParse(f1k) ?? equalizer.frequencies[2].value) ~/ 10),
        equalizer.frequencies[3].copyWith(value: (int.tryParse(f3k) ?? equalizer.frequencies[3].value) ~/ 10),
        equalizer.frequencies[4].copyWith(value: (int.tryParse(f6k) ?? equalizer.frequencies[4].value) ~/ 10),
        equalizer.frequencies[5].copyWith(value: (int.tryParse(f16k) ?? equalizer.frequencies[5].value) ~/ 10),
      ],
    );

    final eqIndex = equalizers.indexWhere((e) => e.equalsFrequencies(newEqualizer));
    if (eqIndex == -1) {
      equalizers[equalizers.indexWhere((e) => e.name == "Custom")] = newEqualizer;
      currentEqualizer.value = newEqualizer;
    } else {
      currentEqualizer.value = equalizers[eqIndex];
    }

    currentZone.value = zone.copyWith(
      active: active == "on" ? true : false,
      volume: int.tryParse(volume) ?? zone.volume,
      balance: int.tryParse(balance) ?? zone.balance,
      equalizer: newEqualizer,
    );

    // currentDevice.value = currentDevice.value.copyWith(zoneWrappers: _getUpdatedZones(currentZone.value));
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
