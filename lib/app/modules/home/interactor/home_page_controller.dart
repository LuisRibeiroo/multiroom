import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:routefly/routefly.dart';
import 'package:signals/signals_flutter.dart';

import '../../../../injector.dart';
import '../../../../routes.g.dart';
import '../../../core/enums/page_state.dart';
import '../../../core/extensions/list_extensions.dart';
import '../../../core/interactor/controllers/base_controller.dart';
import '../../../core/interactor/controllers/socket_mixin.dart';
import '../../../core/interactor/repositories/settings_contract.dart';
import '../../../core/models/channel_model.dart';
import '../../../core/models/device_model.dart';
import '../../../core/models/equalizer_model.dart';
import '../../../core/models/frequency.dart';
import '../../../core/models/project_model.dart';
import '../../../core/models/zone_group_model.dart';
import '../../../core/models/zone_model.dart';
import '../../../core/utils/debouncer.dart';
import '../../../core/utils/mr_cmd_builder.dart';

class HomePageController extends BaseController with SocketMixin {
  HomePageController() : super(InitialState()) {
    projects.value = _settings.projects;
    currentProject.value = projects.firstWhere(
      (p) => p.id == _settings.lastProjectId,
      orElse: () => projects.first,
    );
    expandedViewMode.value = _settings.expandedViewMode;

    if (currentProject.value.devices.isNotEmpty) {
      currentDevice.value = currentProject.value.devices.first;
    }

    currentEqualizer.value = equalizers.last;

    disposables.addAll([
      effect(() {
        if (projects.isEmpty || currentProject.value.devices.isEmpty) {
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
          channels.value = value.zones.first.channels;
        }
      }),
      effect(() {
        projectZones.value = currentProject.value.devices.fold(<ZoneModel>[], (pv, d) => pv..addAll(d.groupedZones));
      }),
    ]);
  }

  final _settings = injector.get<SettingsContract>();

  final projectZones = listSignal<ZoneModel>([], debugLabel: "projectZones");
  final projects = listSignal<ProjectModel>([], debugLabel: "projects");
  final channels = listSignal<ChannelModel>([], debugLabel: "channels");
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
  final generalError = false.toSignal(debugLabel: "generalError");
  final expandedViewMode = false.toSignal(debugLabel: "expandedViewMode");

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
      logger.e(exception);
      setError(Exception("Erro ao enviar comando"));
    }
  }

  Future<void> setProject(ProjectModel proj) async {
    if (currentProject.value.id == proj.id) {
      return;
    }

    _settings.lastProjectId == proj.id;
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

  void setCurrentZone({required ZoneModel zone}) {
    currentZone.value = zone;
  }

  void setViewMode({required bool expanded}) {
    expandedViewMode.value = expanded;
    _settings.expandedViewMode = expanded;
  }

  void _updateProject({required ZoneModel zone}) {
    ZoneGroupModel? group;

    if (zone.isGroup) {
      group = currentDevice.value.groups.firstWhereOrNull((g) => g.zones.containsZone(zone));
    }

    final updatedZone = zone.isGroup ? zone.copyWith(name: group?.getZone(zone.id).name) : zone;
    final updatedGroup = group?.copyWith(
      zones: group.zones.withReplacement(
        (z) => z.id == zone.id,
        updatedZone,
      ),
    );
    final updatedGroups = group == null
        ? null
        : currentDevice.value.groups.withReplacement(
            (g) => g.id == group!.id,
            updatedGroup!,
          );
    final updatedWrapper =
        currentDevice.value.zoneWrappers.firstWhere((w) => w.id == zone.wrapperId).copyWith(zone: updatedZone);

    final updatedWrappers = currentDevice.value.zoneWrappers.withReplacement(
      (w) => w.id == updatedWrapper.id,
      updatedWrapper,
    );

    final newDevice = currentDevice.value.copyWith(
      zoneWrappers: updatedWrappers,
      groups: updatedGroups,
    );

    final updatedDevices = currentProject.value.devices.withReplacement(
      (d) => d.serialNumber == newDevice.serialNumber,
      newDevice,
    );

    currentDevice.value = newDevice;
    currentProject.value = currentProject.value.copyWith(
      devices: updatedDevices,
    );
  }

  Future<void> _updateSignals({ProjectModel? project}) async {
    currentProject.value = project ?? projects.value.first;
    currentDevice.value = currentProject.value.devices.first;
    final zone = currentDevice.value.zones.first;

    if (currentDevice.value.isZoneInGroup(zone)) {
      currentZone.value = currentDevice.value.groups.firstWhere((g) => g.zones.containsZone(zone)).asZone;
    } else {
      currentZone.value = zone;
    }

    channels.value = currentZone.value.channels;

    await run(() async {
      try {
        await restartSocket(ip: currentDevice.value.ip);
        await _updateAllDeviceData(currentZone.value);
      } catch (exception) {
        logger.e(exception);
        setError(Exception("Erro iniciar comunicação com o Multiroom"));
      }
    });
  }

  Future<void> _debounceSendCommand(String cmd) async {
    _writeDebouncer(() async {
      try {
        await socketSender(cmd);
      } catch (exception) {
        logger.e("Erro no comando [$cmd] --> $exception");
        // setError(Exception("Erro no comando [$cmd] --> $exception"));
        setError(Exception("Erro ao enviar comando"));

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
  }

  @override
  void dispose() {
    super.dispose();
    mixinDispose();

    projects.value = <ProjectModel>[];

    currentProject.value = currentProject.initialValue;
    currentDevice.value = currentDevice.initialValue;
    currentZone.value = currentZone.initialValue;
    currentEqualizer.value = currentEqualizer.initialValue;
  }
}
