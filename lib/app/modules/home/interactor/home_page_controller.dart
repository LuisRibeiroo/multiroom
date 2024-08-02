import 'dart:async';

import 'package:flutter/material.dart';
import 'package:multiroom/app/core/extensions/list_extensions.dart';
import 'package:routefly/routefly.dart';
import 'package:signals/signals_flutter.dart';

import '../../../../injector.dart';
import '../../../../routes.g.dart';
import '../../../core/enums/page_state.dart';
import '../../../core/interactor/controllers/base_controller.dart';
import '../../../core/interactor/controllers/socket_mixin.dart';
import '../../../core/interactor/repositories/settings_contract.dart';
import '../../../core/models/channel_model.dart';
import '../../../core/models/device_model.dart';
import '../../../core/models/equalizer_model.dart';
import '../../../core/models/frequency.dart';
import '../../../core/models/project_model.dart';
import '../../../core/models/zone_model.dart';
import '../../../core/utils/debouncer.dart';
import '../../../core/utils/mr_cmd_builder.dart';

class HomePageController extends BaseController with SocketMixin {
  HomePageController() : super(InitialState()) {
    projects.value = _settings.projects;
    currentProject.value = projects.first;
    expandedMode.value = _settings.expandedViewMode;

    if (currentProject.value.devices.isNotEmpty) {
      currentDevice.value = currentProject.value.devices.first;
    }

    currentEqualizer.value = equalizers.last;

    disposables.addAll([
      effect(() {
        if (projects.isEmpty) {
          Routefly.replace(routePaths.modules.configs.pages.configs);
          Routefly.pushNavigate(routePaths.modules.configs.pages.configs);
        }

        hasMultipleProjects.value = projects.length > 1;
      }),
      effect(() {
        if (state.value is SuccessState) {
          restartSocket(ip: currentDevice.value.ip);
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
      }),
      effect(() {
        projectZones.value = currentProject.value.devices.fold(<ZoneModel>[], (pv, d) => pv..addAll(d.zones));
      }),
    ]);
  }

  final _settings = injector.get<SettingsContract>();

  final projectZones = listSignal<ZoneModel>([], debugLabel: "projectZones");
  final projects = listSignal<ProjectModel>([], debugLabel: "projects");
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

  final currentProject = ProjectModel.empty().toSignal(debugLabel: "currentProject");
  final currentDevice = DeviceModel.empty().toSignal(debugLabel: "currentDevice");
  final currentZone = ZoneModel.empty().toSignal(debugLabel: "currentZone");
  final currentEqualizer = EqualizerModel.empty().toSignal(debugLabel: "currentEqualizer");
  final hasMultipleProjects = false.toSignal(debugLabel: "hasMultipleProjects");
  final expandedMode = true.toSignal(debugLabel: "expandedMode");

  final _writeDebouncer = Debouncer(delay: Durations.short4);

  Future<void> setCurrentDeviceAndZone(DeviceModel device, ZoneModel zone) async {
    try {
      channels.set(zone.channels);

      if (device.serialNumber != currentDevice.value.serialNumber) {
        currentDevice.value = device;
        await run(() => restartSocket(ip: device.ip));
      }

      if (currentDevice.previousValue!.serialNumber != currentDevice.value.serialNumber ||
          currentZone.value.id != zone.id) {
        logger.i("UPDATE ALL DATA");
        await _updateAllDeviceData(zone);
      }
    } catch (exception) {
      if (exception is Exception) {
        setError(exception);
      } else {
        setError(Exception(exception));
      }
    }
  }

  Future<void> setProject(ProjectModel proj) async {
    if (currentProject.value.id == proj.id) {
      return;
    }

    _updateSignals(project: proj);
  }

  Future<void> setZoneActive(bool active, {ZoneModel? zone}) async {
    currentZone.value = currentZone.value.copyWith(active: active);

    _debounceSendCommand(
      MrCmdBuilder.setPower(
        zone: zone ?? currentZone.value,
        active: active,
      ),
    );

    if (zone != null) {
      _updateProject(zone: zone.copyWith(active: active));
    } else {
      _updateProject(zone: currentZone.value);
    }
  }

  void setCurrentChannel(ChannelModel channel, {ZoneModel? zone}) {
    if (channel.id == (zone?.channel.id ?? currentZone.value.channel.id)) {
      logger.i("SET CHANNEL [SAME CHANNEL] --> ${channel.id}");
      return;
    }

    final channelIndex = channels.indexWhere((c) => c.id == channel.id);
    final tempList = List<ChannelModel>.from(channels);

    tempList[channelIndex] = channel;

    currentZone.value = currentZone.value.copyWith(
      channels: tempList,
      channel: channel,
    );

    _debounceSendCommand(
      MrCmdBuilder.setChannel(
        zone: zone ?? currentZone.value,
        channel: channel,
      ),
    );

    if (zone != null) {
      _updateProject(zone: zone.copyWith(channel: channel));
    } else {
      _updateProject(zone: currentZone.value);
    }
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

  void setVolume(int volume, {ZoneModel? zone}) {
    currentZone.value = currentZone.value.copyWith(volume: volume);

    _debounceSendCommand(
      MrCmdBuilder.setVolume(
        zone: zone ?? currentZone.value,
        volume: volume,
      ),
    );

    if (zone != null) {
      _updateProject(zone: zone.copyWith(volume: volume));
    } else {
      _updateProject(zone: currentZone.value);
    }
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

  Future<void> syncLocalData() async {
    await run(() {
      projects.value = _settings.projects;

      disposables.addAll(
        [
          untracked(() {
            if (projects.isEmpty) {
              return;
            }

            _updateSignals();
            return null;
          }),
        ],
      );
    });
  }

  void toggleExpandedMode() {
    expandedMode.value = !expandedMode.value;
    _settings.expandedViewMode = expandedMode.value;
  }

  void _updateProject({required ZoneModel zone}) {
    final newWrapper = currentDevice.peek().zoneWrappers.firstWhere((w) => w.id == zone.wrapperId);
    final newDevice = currentDevice.peek().copyWith(
          zoneWrappers: currentDevice.peek().zoneWrappers
            ..replaceWhere(
              (w) => w.id == newWrapper.id,
              newWrapper.copyWith(zone: zone),
            ),
        );

    currentProject.value = currentProject.peek().copyWith(
          devices: currentProject.peek().devices
            ..replaceWhere(
              (d) => d.serialNumber == newDevice.serialNumber,
              newDevice,
            ),
        );
  }

  Future<void> _updateSignals({ProjectModel? project}) async {
    currentProject.value = project ?? projects.value.first;
    currentDevice.value = currentProject.value.devices.first;
    zones.value = currentDevice.value.zones;

    if (currentDevice.value.isZoneInGroup(zones.first)) {
      currentZone.value = currentDevice.value.groups.firstWhere((g) => g.zones.contains(zones.first)).asZone;
    } else {
      currentZone.value = zones.first;
    }

    channels.value = currentZone.value.channels;

    await run(() async {
      try {
        await restartSocket(ip: currentDevice.value.ip);
        await _updateAllDeviceData(currentZone.value);
      } catch (exception) {
        if (exception is Exception) {
          setError(exception);
        } else {
          setError(Exception(exception));
        }
      }
    });
  }

  Future<void> _debounceSendCommand(String cmd) async {
    _writeDebouncer(() async {
      try {
        await socketSender(cmd);
      } catch (exception) {
        setError(Exception("Erro no comando [$cmd] --> $exception"));

        if (exception.toString().contains("Bad state")) {
          await restartSocket(ip: currentDevice.value.ip);
        }
      }
    });
  }

  Future<void> _updateAllDeviceData(ZoneModel zone) async {
    while (socketInit == false) {
      await Future.delayed(Durations.short3);
    }

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

    final f250 = MrCmdBuilder.parseResponse(await socketSender(
      MrCmdBuilder.getEqualizer(
        zone: zone,
        frequency: zone.equalizer.frequencies[1],
      ),
    ));

    final f1k = MrCmdBuilder.parseResponse(await socketSender(
      MrCmdBuilder.getEqualizer(
        zone: zone,
        frequency: zone.equalizer.frequencies[2],
      ),
    ));

    final f3k = MrCmdBuilder.parseResponse(await socketSender(
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
      channel: channels.value.firstWhere(
        (c) => c.id.trim() == channelStr.trim(),
        orElse: () => channels.first,
      ),
    );

    _updateProject(zone: currentZone.value);

    // currentDevice.value = currentDevice.value.copyWith(zoneWrappers: _getUpdatedZones(currentZone.value));
  }

  @override
  void dispose() {
    super.dispose();
    mixinDispose();

    projects.value = <ProjectModel>[];
    zones.value = <ZoneModel>[];

    currentProject.value = currentProject.initialValue;
    currentDevice.value = currentDevice.initialValue;
    currentZone.value = currentZone.initialValue;
    currentEqualizer.value = currentEqualizer.initialValue;
    expandedMode.value = expandedMode.initialValue;
  }
}
