import 'dart:async';
import 'dart:io';

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
    currentProject.value = _getLastProject();
    expandedViewMode.value = _settings.expandedViewMode;

    if (currentProject.value.devices.isNotEmpty) {
      currentDevice.value = currentProject.value.devices.first;
    }

    currentEqualizer.value = equalizers.last;

    disposables["$runtimeType"] = [
      effect(() {
        if (projects.isEmpty || currentProject.value.devices.isEmpty) {
          Routefly.replace(routePaths.modules.configs.pages.configs);
          Routefly.pushNavigate(routePaths.modules.configs.pages.configs);
        } else {
          projectZones.value = currentProject.value.devices.fold(<ZoneModel>[], (pv, d) => pv..addAll(d.groupedZones));
          _settings.lastProjectId = currentProject.value.id;
        }
      }),
      currentDevice.subscribe((value) async {
        if (value.isEmpty) {
          return;
        }

        if (value.serialNumber != currentDevice.previousValue!.serialNumber) {
          channels.value = value.zones.first.channels;
        }

        _settings.saveDevice(device: currentDevice.value);
      }),
      effect(() {
        if (expandedViewMode.value) {
          if (currentZone.value.isEmpty == false) {
            if (currentZone.value.id != currentZone.previousValue?.id) {
              _writeDebouncer(() async {
                await updateEqualizer(newZone: currentZone.peek());
              });
            }
          }
        }
      })
      // effect(() async {
      //   if (_isPageVisible.value && _monitorController.hasStateChanges.value) {
      //     untracked(() async {
      //       await syncLocalData(
      //         awaitUpdate: true,
      //         readAllZones: true,
      //       );

      //       _monitorController.ingestStateChanges();
      //     });
      //   }
      // })
    ];
  }

  final _settings = injector.get<SettingsContract>();
  // final _monitorController = injector.get<DeviceMonitorController>();

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

  final currentProject = ProjectModel.empty().asSignal(debugLabel: "currentProject");
  final currentDevice = DeviceModel.empty().asSignal(debugLabel: "currentDevice");
  final currentZone = ZoneModel.empty().asSignal(debugLabel: "currentZone");
  final currentEqualizer = EqualizerModel.empty().asSignal(debugLabel: "currentEqualizer");
  final expandedViewMode = false.asSignal(debugLabel: "expandedViewMode");

  final _writeDebouncer = Debouncer(delay: Durations.short4);
  final _updatingData = false.asSignal(debugLabel: "updatingData");

  final _isPageVisible = false.asSignal(debugLabel: "homePageVisible");

  void setPageVisible(bool visible) => _isPageVisible.value = visible;

  // void startDeviceMonitor() => _monitorController.startDeviceMonitor(callerName: "HomePageController");

  Future<void> setCurrentDeviceAndZone(DeviceModel device, ZoneModel zone) async {
    try {
      channels.set(zone.channels);

      if (device.serialNumber != currentDevice.value.serialNumber) {
        currentDevice.value = device;
        await run(() => restartSocket(ip: device.ip));
      }

      if (currentDevice.previousValue!.serialNumber != currentDevice.value.serialNumber ||
          currentZone.value.id != zone.id) {
        currentZone.value = zone;
        currentDevice.value = device;
      }
    } catch (exception) {
      logger.e(exception);

      _setOfflineDeviceState();
      setError(Exception("Erro ao enviar comando"));
    }
  }

  Future<void> setProject(ProjectModel proj) async {
    if (currentProject.value.id == proj.id) {
      return;
    }

    _settings.lastProjectId = proj.id;
    state.value = const SuccessState(data: null);

    await _updateDevicesState();

    await _updateSignals(
      project: proj,
      allDevices: true,
    );
  }

  Future<void> setZoneActive(bool active, {ZoneModel? zone}) async {
    currentZone.value = currentZone.value.copyWith(active: active);

    _debounceSendCommand(
      MrCmdBuilder.setPower(
        macAddress: zone?.macAddress ?? currentZone.value.macAddress,
        zone: zone ?? currentZone.value,
        active: active,
      ),
    );

    if (zone != null) {
      _updateZonesInProject(zones: [zone.copyWith(active: active)]);
    } else {
      _updateZonesInProject(zones: [currentZone.value]);
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
        macAddress: zone?.macAddress ?? currentZone.value.macAddress,
        zone: zone ?? currentZone.value,
        channel: channel,
      ),
    );

    if (zone != null) {
      _updateZonesInProject(zones: [zone.copyWith(channel: channel)]);
    } else {
      _updateZonesInProject(zones: [currentZone.value]);
    }
  }

  void setBalance(int balance) {
    currentZone.value = currentZone.value.copyWith(balance: balance);

    _debounceSendCommand(
      MrCmdBuilder.setBalance(
        macAddress: currentZone.value.macAddress,
        zone: currentZone.value,
        balance: balance,
      ),
    );

    _updateZonesInProject(zones: [currentZone.value]);
  }

  void setVolume(int volume, {ZoneModel? zone}) {
    currentZone.value = currentZone.value.copyWith(volume: volume);

    _debounceSendCommand(
      MrCmdBuilder.setVolume(
        macAddress: zone?.macAddress ?? currentZone.value.macAddress,
        zone: zone ?? currentZone.value,
        volume: volume,
      ),
    );

    if (zone != null) {
      _updateZonesInProject(zones: [zone.copyWith(volume: volume)]);
    } else {
      _updateZonesInProject(zones: [currentZone.value]);
    }
  }

  Future<EqualizerModel> updateEqualizer({ZoneModel? newZone}) async {
    if (currentDevice.value.active == false) {
      setError(Exception("Dispositivo offline"));
    }

    final zone = newZone ?? currentZone.value;
    final f60 = MrCmdBuilder.parseResponseSingle(await socketSender(
      MrCmdBuilder.getEqualizer(
        macAddress: zone.macAddress,
        zone: zone,
        frequency: zone.equalizer.frequencies[0],
      ),
    ));

    final f250 = MrCmdBuilder.parseResponseSingle(await socketSender(
      MrCmdBuilder.getEqualizer(
        macAddress: zone.macAddress,
        zone: zone,
        frequency: zone.equalizer.frequencies[1],
      ),
    ));

    final f1k = MrCmdBuilder.parseResponseSingle(await socketSender(
      MrCmdBuilder.getEqualizer(
        macAddress: zone.macAddress,
        zone: zone,
        frequency: zone.equalizer.frequencies[2],
      ),
    ));

    final f3k = MrCmdBuilder.parseResponseSingle(await socketSender(
      MrCmdBuilder.getEqualizer(
        macAddress: zone.macAddress,
        zone: zone,
        frequency: zone.equalizer.frequencies[3],
      ),
    ));

    final f6k = MrCmdBuilder.parseResponseSingle(await socketSender(
      MrCmdBuilder.getEqualizer(
        macAddress: zone.macAddress,
        zone: zone,
        frequency: zone.equalizer.frequencies[4],
      ),
    ));

    final f16k = MrCmdBuilder.parseResponseSingle(await socketSender(
      MrCmdBuilder.getEqualizer(
        macAddress: zone.macAddress,
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

    // currentZone.value = zone.copyWith(equalizer: newEqualizer);

    return currentEqualizer.value;
  }

  Future<void> setEqualizer(EqualizerModel equalizer) async {
    if (currentDevice.value.active == false) {
      setError(Exception("Dispositivo offline"));
    }

    if (equalizer == currentEqualizer.value) {
      logger.i("SET EQUALIZER [SAME EQUALIZER] --> $equalizer");
      return;
    }

    currentEqualizer.value = equalizers.firstWhere((e) => e.name == equalizer.name);
    currentZone.value = currentZone.value.copyWith(equalizer: currentEqualizer.value);

    for (final freq in currentZone.value.equalizer.frequencies) {
      await socketSender(
        MrCmdBuilder.setEqualizer(
          macAddress: currentZone.value.macAddress,
          zone: currentZone.value,
          frequency: freq,
          gain: freq.value,
        ),
      );

      // Delay to avoid sending commands too fast
      await Future.delayed(Durations.short2);
    }

    _updateZonesInProject(zones: [currentZone.value]);
  }

  void setFrequency(Frequency frequency) {
    final freqIndex = currentEqualizer.value.frequencies.indexWhere((f) => f.id == frequency.id);
    final tempList = List<Frequency>.from(currentEqualizer.value.frequencies);

    tempList[freqIndex] = currentEqualizer.value.frequencies[freqIndex].copyWith(value: frequency.value.toInt());

    currentEqualizer.value = EqualizerModel.custom(frequencies: tempList);
    currentZone.value = currentZone.value.copyWith(equalizer: currentEqualizer.value);

    _debounceSendCommand(
      // socketSender(
      MrCmdBuilder.setEqualizer(
        macAddress: currentZone.value.macAddress,
        zone: currentZone.value,
        frequency: frequency,
        gain: frequency.value,
        // )
      ),
    );

    _updateZonesInProject(zones: [currentZone.value]);
  }

  Future<void> syncLocalData({
    bool awaitUpdate = true,
    bool allDevices = false,
  }) async {
    // if (state.value is LoadingState) {
    //   return;
    // }

    await run(() async {
      projects.value = _settings.projects;

      if (projects.isEmpty) {
        return;
      }

      if (allDevices) {
        await _updateDevicesState();
      }

      if (awaitUpdate) {
        await _updateSignals(allDevices: allDevices);
      } else {
        _updateSignals(allDevices: allDevices);
      }
    });
  }

  Future<void> setCurrentZone({required ZoneModel zone}) async {
    currentZone.value = zone;
    channels.value = currentZone.value.channels;
    // currentEqualizer.value = currentZone.value.equalizer;
  }

  void setViewMode({required bool expanded}) {
    expandedViewMode.value = expanded;
    _settings.expandedViewMode = expanded;
  }

  Future<void> onFactoryRestore() async {
    await run(
      setError: true,
      () async {
        try {
          await _iterateOverDevices(function: (device) async {
            await socketSender(MrCmdBuilder.setDefaultParams(macAddress: device.macAddress));
          });

          await _updateSignals(allDevices: true);
        } catch (exception) {
          logger.e("Erro ao resetar dispositivo --> $exception");
          setError(Exception("Erro ao enviar comando"));
        }
      },
    );
  }

  ProjectModel _getLastProject() {
    return projects.firstWhere(
      (p) => p.id == _settings.lastProjectId,
      orElse: () => projects.first,
    );
  }

  Future<void> _iterateOverDevices({required Function(DeviceModel) function}) async {
    for (final device in currentProject.value.devices) {
      await function(device);
    }
  }

  void _setOfflineDeviceState() {
    if (currentDevice.value.active) {
      currentDevice.value = currentDevice.value.copyWith(active: false);
      _settings.saveDevice(device: currentDevice.value);

      _updateDeviceInProject(device: currentDevice.value);
    }
  }

  Future<void> _updateDevicesState() async {
    currentProject.value = _getLastProject();

    await _iterateOverDevices(function: (d) async {
      DeviceModel newDevice;

      try {
        await Socket.connect(
          d.ip,
          4998,
          timeout: const Duration(seconds: 1),
        ).then((s) => s.close());

        newDevice = d.copyWith(active: true);
      } catch (exception) {
        newDevice = d.copyWith(active: false);
      }

      if (currentDevice.value.serialNumber == newDevice.serialNumber) {
        currentDevice.value = newDevice;
      }

      _updateDeviceInProject(device: newDevice);
    });
  }

  Future<void> _updateZonesInProject({required List<ZoneModel> zones}) async {
    for (ZoneModel zone in zones) {
      ZoneGroupModel? group;
      final isZoneGrouped = currentDevice.value.isZoneInGroup(zone);

      if (isZoneGrouped) {
        group = currentDevice.value.groups.firstWhereOrNull((g) => g.zones.containsZone(zone));
      }

      final updatedZone = isZoneGrouped ? zone.copyWith(name: group?.getZone(zone.id).name) : zone;

      logger.i("[DBG] UPDATE PROJECT --> ${isZoneGrouped ? group?.name : zone.name}");
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

      currentDevice.value = currentDevice.value.copyWith(
        zoneWrappers: updatedWrappers,
        groups: updatedGroups,
      );

      _updateDeviceInProject(device: currentDevice.value);
    }
  }

  void _updateDeviceInProject({required DeviceModel device}) {
    currentProject.value = currentProject.value.copyWith(
      devices: currentProject.value.devices.withReplacement(
        (d) => d.serialNumber == device.serialNumber,
        device,
      ),
    );
  }

  Future<void> _updateSignals({
    ProjectModel? project,
    bool allDevices = false,
  }) async {
    currentProject.value = project ?? _getLastProject();
    currentDevice.value = currentProject.value.devices.first;

    if (currentProject.value.devices.any((d) => d.active)) {
      // if (currentZone.value.isEmpty) {
      final zone = currentDevice.value.zones.firstWhere(
        (z) => z.id == currentZone.value.id,
        orElse: () => currentDevice.value.zones.first,
      );

      if (currentDevice.value.isZoneInGroup(zone)) {
        currentZone.value = currentDevice.value.groups.firstWhere((g) => g.zones.containsZone(zone)).asZone;
      } else {
        currentZone.value = zone;
      }

      channels.value = currentZone.value.channels;

      currentZone.value = currentZone.value.copyWith(
        channel: channels.firstWhere(
          (c) => c.id == currentZone.value.channel.id,
          orElse: () => channels.first,
        ),
      );
      // }

      await _runUpdateData(allDevices: allDevices);
    }
  }

  Future<void> _runUpdateData({required bool allDevices}) async {
    await run(() async {
      try {
        if (_updatingData.value == false) {
          await restartSocket(ip: currentDevice.value.ip);
        }

        _updatingData.value = true;

        if (allDevices) {
          await _iterateOverDevices(function: (d) => _updateDeviceData(d));
        } else {
          await _updateDeviceData(currentDevice.value);
        }

        _updatingData.value = false;
      } catch (exception) {
        if (exception is StateError && exception.toString().contains("StreamSink")) {
          try {
            await restartSocket(ip: currentDevice.value.ip);

            await _runUpdateData(allDevices: allDevices);
            return;
          } catch (_) {}
        }

        logger.e("Erro ao tentar comunicação com o Multiroom --> $exception");

        _setOfflineDeviceState();
        setError(Exception("Erro ao tentar comunicação com o Multiroom"));

        _updatingData.value = false;
      }
    });
  }

  void _debounceSendCommand(String cmd) {
    _writeDebouncer(() async {
      if (currentDevice.value.active == false) {
        setError(Exception("Dispositivo offline"));

        return;
      }

      try {
        await socketSender(cmd);
        currentDevice.value = currentDevice.value.copyWith(active: true);
      } catch (exception) {
        logger.e("Erro no comando [$cmd] --> $exception");
        // setError(Exception("Erro no comando [$cmd] --> $exception"));
        _setOfflineDeviceState();
        setError(Exception("Erro ao enviar comando"));

        if (exception.toString().contains("Bad state")) {
          await restartSocket(ip: currentDevice.value.ip);
        }
      }
    });
  }

  // Future<void> _updateZoneData(
  //   ZoneModel zone, {
  //   bool updateCurrentZone = true,
  // }) async {
  //   while (socketInit == false) {
  //     await Future.delayed(Durations.short3);
  //   }

  //   // final active = MrCmdBuilder.parseResponseSingle(await socketSender(
  //   //   MrCmdBuilder.getPower(
  //   //     macAddress: zone.macAddress,
  //   //     zone: zone,
  //   //   ),
  //   // ));

  //   // final channelStr = MrCmdBuilder.parseResponseSingle(await socketSender(
  //   //   MrCmdBuilder.getChannel(
  //   //     macAddress: zone.macAddress,
  //   //     zone: zone,
  //   //   ),
  //   // ));

  //   // final volume = MrCmdBuilder.parseResponseSingle(await socketSender(
  //   //   MrCmdBuilder.getVolume(
  //   //     macAddress: zone.macAddress,
  //   //     zone: zone,
  //   //   ),
  //   // ));

  //   // String balance = "0";
  //   // if (zone.isStereo) {
  //   //   balance = MrCmdBuilder.parseResponseSingle(await socketSender(
  //   //     MrCmdBuilder.getBalance(
  //   //       macAddress: zone.macAddress,
  //   //       zone: zone,
  //   //     ),
  //   //   ));
  //   // }

  //   // final f60 = MrCmdBuilder.parseResponseSingle(await socketSender(
  //   //   MrCmdBuilder.getEqualizer(
  //   //     macAddress: zone.macAddress,
  //   //     zone: zone,
  //   //     frequency: zone.equalizer.frequencies[0],
  //   //   ),
  //   // ));

  //   // final f250 = MrCmdBuilder.parseResponseSingle(await socketSender(
  //   //   MrCmdBuilder.getEqualizer(
  //   //     macAddress: zone.macAddress,
  //   //     zone: zone,
  //   //     frequency: zone.equalizer.frequencies[1],
  //   //   ),
  //   // ));

  //   // final f1k = MrCmdBuilder.parseResponseSingle(await socketSender(
  //   //   MrCmdBuilder.getEqualizer(
  //   //     macAddress: zone.macAddress,
  //   //     zone: zone,
  //   //     frequency: zone.equalizer.frequencies[2],
  //   //   ),
  //   // ));

  //   // final f3k = MrCmdBuilder.parseResponseSingle(await socketSender(
  //   //   MrCmdBuilder.getEqualizer(
  //   //     macAddress: zone.macAddress,
  //   //     zone: zone,
  //   //     frequency: zone.equalizer.frequencies[3],
  //   //   ),
  //   // ));

  //   // final f6k = MrCmdBuilder.parseResponseSingle(await socketSender(
  //   //   MrCmdBuilder.getEqualizer(
  //   //     macAddress: zone.macAddress,
  //   //     zone: zone,
  //   //     frequency: zone.equalizer.frequencies[4],
  //   //   ),
  //   // ));

  //   // final f16k = MrCmdBuilder.parseResponseSingle(await socketSender(
  //   //   MrCmdBuilder.getEqualizer(
  //   //     macAddress: zone.macAddress,
  //   //     zone: zone,
  //   //     frequency: zone.equalizer.frequencies[5],
  //   //   ),
  //   // ));

  //   // final equalizer = zone.equalizer;
  //   // final newEqualizer = EqualizerModel.custom(
  //   //   frequencies: [
  //   //     equalizer.frequencies[0].copyWith(value: (int.tryParse(f60) ?? equalizer.frequencies[0].value) ~/ 10),
  //   //     equalizer.frequencies[1].copyWith(value: (int.tryParse(f250) ?? equalizer.frequencies[1].value) ~/ 10),
  //   //     equalizer.frequencies[2].copyWith(value: (int.tryParse(f1k) ?? equalizer.frequencies[2].value) ~/ 10),
  //   //     equalizer.frequencies[3].copyWith(value: (int.tryParse(f3k) ?? equalizer.frequencies[3].value) ~/ 10),
  //   //     equalizer.frequencies[4].copyWith(value: (int.tryParse(f6k) ?? equalizer.frequencies[4].value) ~/ 10),
  //   //     equalizer.frequencies[5].copyWith(value: (int.tryParse(f16k) ?? equalizer.frequencies[5].value) ~/ 10),
  //   //   ],
  //   // );

  //   // final eqIndex = equalizers.indexWhere((e) => e.equalsFrequencies(newEqualizer));
  //   // if (eqIndex == -1) {
  //   //   equalizers[equalizers.indexWhere((e) => e.name == "Custom")] = newEqualizer;
  //   //   currentEqualizer.value = newEqualizer;
  //   // } else {
  //   //   currentEqualizer.value = equalizers[eqIndex];
  //   // }

  //   // final updatedZone = zone.copyWith(equalizer: newEqualizer);

  //   if (updateCurrentZone) {
  //     currentZone.value = zone;
  //   }

  //   await _updateZonesInProject(zones: [zone]);
  // }

  Future<void> _updateDeviceData(DeviceModel device) async {
    await restartSocket(ip: device.ip);

    final activeInfo = MrCmdBuilder.parseResponseAllZones(await socketSender(
      MrCmdBuilder.getPowerAll(macAddress: device.macAddress),
      longRet: true,
    ));

    final channelInfo = MrCmdBuilder.parseResponseAllZones(await socketSender(
      MrCmdBuilder.getChannelAll(macAddress: device.macAddress),
      longRet: true,
    ));

    final volumeInfo = MrCmdBuilder.parseResponseAllZones(await socketSender(
      MrCmdBuilder.getVolumeAll(macAddress: device.macAddress),
      longRet: true,
    ));

    final balanceInfo = MrCmdBuilder.parseResponseAllZones(await socketSender(
      MrCmdBuilder.getBalanceAll(macAddress: device.macAddress),
      longRet: true,
    ));

    final zonesData = ZoneData.buildAllZones(
      powerResponse: activeInfo,
      volumeResponse: volumeInfo,
      channelResponse: channelInfo,
      balanceResponse: balanceInfo,
    );

    // final frequencies = MrCmdBuilder.parseResponseMulti(await socketSender(
    //   MrCmdBuilder.getEqualizerAll(macAddress: device.macAddress),
    //   longRet: true,
    // ));

    // final equalizer = zone.equalizer;
    // final newEqualizer = EqualizerModel.custom(
    //   frequencies: [
    //     equalizer.frequencies[0].copyWith(value: (int.tryParse(f60) ?? equalizer.frequencies[0].value) ~/ 10),
    //     equalizer.frequencies[1].copyWith(value: (int.tryParse(f250) ?? equalizer.frequencies[1].value) ~/ 10),
    //     equalizer.frequencies[2].copyWith(value: (int.tryParse(f1k) ?? equalizer.frequencies[2].value) ~/ 10),
    //     equalizer.frequencies[3].copyWith(value: (int.tryParse(f3k) ?? equalizer.frequencies[3].value) ~/ 10),
    //     equalizer.frequencies[4].copyWith(value: (int.tryParse(f6k) ?? equalizer.frequencies[4].value) ~/ 10),
    //     equalizer.frequencies[5].copyWith(value: (int.tryParse(f16k) ?? equalizer.frequencies[5].value) ~/ 10),
    //   ],
    // );

    // final eqIndex = equalizers.indexWhere((e) => e.equalsFrequencies(newEqualizer));
    // if (eqIndex == -1) {
    //   equalizers[equalizers.indexWhere((e) => e.name == "Custom")] = newEqualizer;
    //   currentEqualizer.value = newEqualizer;
    // } else {
    //   currentEqualizer.value = equalizers[eqIndex];
    // }

    // final updatedZone = zone.copyWith(
    //   active: active.toLowerCase() == "on" ? true : false,
    //   volume: int.tryParse(volume) ?? zone.volume,
    //   balance: int.tryParse(balance) ?? zone.balance,
    //   equalizer: newEqualizer,
    //   channel: channels.value.firstWhere(
    //     (c) => c.id.trim() == channelStr.trim(),
    //     orElse: () => channels.first,
    //   ),
    // );

    // if (updateCurrentZone) {
    //   currentZone.value = updatedZone;
    // }

    final zones = <ZoneModel>[];

    for (final zoneData in zonesData) {
      final zone = device.zones.firstWhereOrNull((z) => z.id == zoneData.zoneId);

      if (zone == null) {
        continue;
      }

      final channel = zone.channels.firstWhere(
        (c) => c.id == zoneData.values.channel,
        orElse: () => channels.first,
      );

      zones.add(zone.copyWith(
        active: zoneData.values.power,
        volume: zoneData.values.volume,
        channel: channel,
        balance: zoneData.values.balance,
      ));
    }

    await _updateZonesInProject(zones: zones.grouped(device.groups));
  }

  void dispose() {
    super.baseDispose(key: "$runtimeType");
    mixinDispose();
    // _monitorController.stopDeviceMonitor();

    projects.value = <ProjectModel>[];

    currentProject.value = currentProject.initialValue;
    currentDevice.value = currentDevice.initialValue;
    currentZone.value = currentZone.initialValue;
    currentEqualizer.value = currentEqualizer.initialValue;
  }
}
