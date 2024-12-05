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
import '../../../core/extensions/string_extensions.dart';
import '../../../core/interactor/controllers/base_controller.dart';
import '../../../core/interactor/controllers/socket_mixin.dart';
import '../../../core/interactor/repositories/settings_contract.dart';
import '../../../core/models/channel_model.dart';
import '../../../core/models/device_model.dart';
import '../../../core/models/equalizer_model.dart';
import '../../../core/models/frequency.dart';
import '../../../core/models/project_model.dart';
import '../../../core/models/socket_connection.dart';
import '../../../core/models/zone_group_model.dart';
import '../../../core/models/zone_model.dart';
import '../../../core/models/zone_wrapper_model.dart';
import '../../../core/utils/constants.dart';
import '../../../core/utils/debouncer.dart';
import '../../../core/utils/mr_cmd_builder.dart';

class HomePageController extends BaseController with SocketMixin {
  HomePageController() : super(InitialState()) {
    currentProject.value = _getLastProject();
    expandedViewMode.value = _settings.expandedViewMode;

    if (currentProject.value.devices.isNotEmpty) {
      currentDevice.value = currentProject.value.devices.first;
      currentZone.value = currentDevice.value.groupedZones.first;
    }

    currentEqualizer.value = equalizers.last;

    _future();

    disposables["$runtimeType"] = [
      effect(() {
        if (projects.isEmpty || currentProject.value.devices.isEmpty) {
          Routefly.replace(routePaths.modules.configs.pages.configs);
          Routefly.pushNavigate(routePaths.modules.configs.pages.configs);
        }
      }),
      effect(() {
        if (expandedViewMode.value) {
          if (currentZone.value.isEmpty == false) {
            if (currentZone.value.hashCode != currentZone.previousValue?.hashCode) {
              _writeDebouncer(() async {
                await _setCurrentDeviceByMacAdress(mac: currentZone.value.macAddress);
                await updateEqualizer(updatedZone: currentZone.peek());
              });
            }
          }
        }
      }),
      effect(() {
        allDevicesOnline.value = currentProject.value.devices.every((device) => device.active);
      }),
      effect(() {
        anyZoneOnInProject.value = projectZones.any((z) => z.active);
      }),
      effect(() {
        hasFilteredZones.value =
            searchIsVisible.value && (searchText.value.isNotNullOrEmpty || filteredProjectZones.isNotEmpty);
      }),
      currentProject.subscribe((project) {
        projectZones.value = project.devices.fold(
          <ZoneModel>[],
          (pv, d) => pv..addAll(d.groupedZones),
        );

        // projectZones.value.sort((a, b) => a.name.compareTo(b.name));
        _settings.lastProjectId = project.id;
        //  _settings.saveProject(currentProject.value);
      }),
      effect(() {
        filteredProjectZones.value =
            projectZones.value.where((z) => z.name.toUpperCase().contains(searchText.value)).toList();
      }),
    ];
  }

  final _settings = injector.get<SettingsContract>();
  final searchIsVisible = false.asSignal(debugLabel: "searchIsVisible");
  final searchText = "".asSignal(debugLabel: "searchText");
  final filteredProjectZones = listSignal<ZoneModel>([], debugLabel: "projectZonesFiltered");
  final projectZones = listSignal<ZoneModel>([], debugLabel: "projectZones");
  final projects = listSignal<ProjectModel>([], debugLabel: "projects");
  final equalizers = <EqualizerModel>[
    EqualizerModel.builder(name: "Rock", v60: 2, v250: 0, v1k: 1, v3k: 2, v6k: 2, v16k: 1),
    EqualizerModel.builder(name: "Pop", v60: 2, v250: 1, v1k: 2, v3k: 3, v6k: 2, v16k: 2),
    EqualizerModel.builder(name: "Clássico", v60: 1, v250: 0, v1k: 1, v3k: 2, v6k: 1, v16k: 1),
    EqualizerModel.builder(name: "Jazz", v60: 1, v250: 0, v1k: 2, v3k: 3, v6k: 2, v16k: 1),
    EqualizerModel.builder(name: "Dance Music", v60: 4, v250: 2, v1k: 0, v3k: 3, v6k: 3, v16k: 2),
    EqualizerModel.builder(name: "Flat", v60: 0, v250: 0, v1k: 0, v3k: 0, v6k: 0, v16k: 0),
    EqualizerModel.builder(name: "Custom"),
  ];

  final currentProject = ProjectModel.empty().asSignal(debugLabel: "currentProject");
  final currentDevice = DeviceModel.empty().asSignal(debugLabel: "currentDevice");
  final currentZone = ZoneModel.empty().asSignal(debugLabel: "currentZone");
  final currentEqualizer = EqualizerModel.empty().asSignal(debugLabel: "currentEqualizer");
  final expandedViewMode = false.asSignal(debugLabel: "expandedViewMode");
  final allDevicesOnline = false.asSignal(debugLabel: "allDevicesOnline");
  final anyZoneOnInProject = false.asSignal(debugLabel: "anyZoneOnInProject");
  final hasFilteredZones = false.asSignal(debugLabel: "hasFilteredZones");

  final _writeDebouncer = Debouncer(delay: Durations.short4);

  final _isPageVisible = false.asSignal(debugLabel: "homePageVisible");

  void setPageVisible(bool visible) => _isPageVisible.value = visible;

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

  Future<void> setZoneActive(bool active, ZoneModel zone) async {
    currentZone.value = zone.copyWith(active: active);
    await _setCurrentDeviceByMacAdress(mac: currentZone.value.macAddress);

    _debounceSendCommand(
      MrCmdBuilder.setPower(
        macAddress: currentZone.value.macAddress,
        zone: currentZone.value,
        active: active,
      ),
      debounce: false,
      onError: () {
        currentZone.value = zone;
        _updateZonesInProject(zones: [currentZone.value]);
      },
    );

    _updateZonesInProject(zones: [currentZone.value]);
  }

  Future<void> setCurrentChannel(
    ChannelModel channel,
    ZoneModel zone,
    List<ChannelModel> channels,
  ) async {
    currentDevice.value = currentDevice.value.copyWith(channels: channels);
    currentZone.value = zone.copyWith(channel: channel);
    await _setCurrentDeviceByMacAdress(mac: currentZone.value.macAddress);

    _debounceSendCommand(
      MrCmdBuilder.setChannel(
        macAddress: currentZone.value.macAddress,
        zone: currentZone.value,
        channel: channel,
      ),
      debounce: false,
      onError: () {
        currentZone.value = zone;
        _updateZonesInProject(zones: [currentZone.value]);
      },
    );

    _updateZonesInProject(zones: [currentZone.value]);
  }

  void setBalance(int balance) {
    currentZone.value = currentZone.value.copyWith(balance: balance);

    _debounceSendCommand(
      MrCmdBuilder.setBalance(
        macAddress: currentZone.value.macAddress,
        zone: currentZone.value,
        balance: balance,
      ),
      onError: () {
        currentZone.value = currentZone.previousValue!;
        _updateZonesInProject(zones: [currentZone.value]);
      },
    );

    _updateZonesInProject(zones: [currentZone.value]);
  }

  Future<void> setVolume(int volume, {ZoneModel? zone}) async {
    currentZone.value = (zone ?? currentZone.value).copyWith(volume: volume);
    await _setCurrentDeviceByMacAdress(mac: currentZone.value.macAddress);

    _debounceSendCommand(
      MrCmdBuilder.setVolume(
        macAddress: zone?.macAddress ?? currentZone.value.macAddress,
        zone: zone ?? currentZone.value,
        volume: volume,
      ),
      onError: () {
        currentZone.value = currentZone.previousValue!;
        _updateZonesInProject(zones: [currentZone.value]);
      },
    );

    _updateZonesInProject(zones: [currentZone.value]);
  }

  Future<void> updateEqualizer({ZoneModel? updatedZone}) async {
    final zone = updatedZone ?? currentZone.value;

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
  }

  Future<void> setEqualizer(EqualizerModel equalizer) async {
    await run(() async {
      try {
        for (final freq in equalizer.frequencies) {
          await socketSender(
            // TODO: Update to use ALL cmd
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

        currentEqualizer.value = equalizer;
        currentZone.value = currentZone.value.copyWith(equalizer: currentEqualizer.value);
      } catch (exception) {
        logger.e("Erro ao configurar equalizador --> $exception");
        currentEqualizer.value = currentEqualizer.previousValue!;
        currentZone.value = currentZone.previousValue!;

        _updateDevicesState();
        setError(Exception("Erro ao enviar comando"));
      }

      _updateZonesInProject(zones: [currentZone.value]);
    });
  }

  void setFrequency(Frequency frequency) {
    final freqIndex = currentEqualizer.value.frequencies.indexWhere((f) => f.id == frequency.id);
    final tempList = List<Frequency>.from(currentEqualizer.value.frequencies);

    tempList[freqIndex] = currentEqualizer.value.frequencies[freqIndex].copyWith(value: frequency.value.toInt());

    currentEqualizer.value = EqualizerModel.custom(frequencies: tempList);
    currentZone.value = currentZone.value.copyWith(equalizer: currentEqualizer.value);

    _debounceSendCommand(
      MrCmdBuilder.setEqualizer(
        macAddress: currentZone.value.macAddress,
        zone: currentZone.value,
        frequency: frequency,
        gain: frequency.value,
      ),
      onError: () {
        currentEqualizer.value = currentEqualizer.previousValue!;
        currentZone.value = currentZone.previousValue!;

        _updateZonesInProject(zones: [currentZone.value]);
      },
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

      // if (allDevices) {
      //   await _updateDevicesState();
      // }

      // if (awaitUpdate) {
      //   await _updateSignals(allDevices: allDevices);
      // } else {
      //   _updateSignals(allDevices: allDevices);
      // }
    });
  }

  Future<void> setCurrentZone({required ZoneModel zone}) async {
    currentZone.value = zone;

    await _setCurrentDeviceByMacAdress(mac: zone.macAddress);
  }

  void setViewMode({required bool expanded}) {
    expandedViewMode.value = expanded;
    _settings.expandedViewMode = expanded;
  }

  Future<bool> onFactoryRestore() async {
    var result = false;
    await run(
      setError: true,
      () async {
        try {
          await _iterateOverDevices(function: (device) async {
            await socketSender(MrCmdBuilder.setDefaultParams(macAddress: device.macAddress));
          });

          await _updateSignals(allDevices: true);
          result = true;
        } catch (exception) {
          logger.e("Erro ao resetar dispositivo --> $exception");
          setError(Exception("Erro ao enviar comando"));
          result = false;
        }
      },
    );

    return result;
  }

  Future<void> onConfirmDisableAllZones() async {
    await run(
      setError: true,
      () async {
        try {
          await _iterateOverDevices(function: (d) async {
            await socketSender(MrCmdBuilder.setPowerAll(
              macAddress: d.macAddress,
              active: false,
            ));
          });

          await _updateSignals(allDevices: true);
        } catch (exception) {
          logger.e("Erro ao desabilitar todas as zonas --> $exception");
          setError(Exception("Erro ao enviar comando"));
        }
      },
    );
  }

  void setSearchVisibility(bool value) => searchIsVisible.value = value;

  void setSearchText(String value) => searchText.value = value.toUpperCase();

  Future<void> _future() async {
    // var t = await restartSocket(ip: "192.168.0.19");

    // t.listenString((data) {
    //   print("DATA --> $data");
    // });

    for (final device in currentProject.value.devices) {
      final socket = await initSocket(ip: device.ip);

      connections.addAll({
        device.ip: SocketConnection(
          ip: device.ip,
          macAddress: device.macAddress,
          socket: socket,
        ),
      });
    }

    connections.listenAll(
      onData: (data) {
        final t = MrCmdBuilder.parseResponseAsync(data);
        print(t);
      },
    );
  }

  Future<void> sendTestData() async {
    _getDeviceData(currentDevice.value);
  }

  ProjectModel _getLastProject() {
    projects.value = _settings.projects;

    return projects.firstWhere(
      (p) => p.id == _settings.lastProjectId,
      orElse: () => projects.first,
    );
  }

  Future<void> _setCurrentDeviceByMacAdress({required String mac}) async {
    final device = currentProject.value.devices.firstWhere((d) => d.macAddress == mac);

    if (mac == currentDevice.value.macAddress && device.ip == socketCurrentiP) {
      return;
    }

    currentDevice.value = device;
    await run(() => restartSocket(ip: currentDevice.value.ip));
  }

  Future<void> _iterateOverDevices({
    required Function(DeviceModel) function,
    bool initSocket = true,
  }) async {
    for (final device in currentProject.value.devices) {
      if (initSocket) {
        await restartSocket(ip: device.ip);
      }

      await function(device);
    }
  }

  Future<void> _updateDevicesState() async {
    currentProject.value = _getLastProject();

    await _iterateOverDevices(
        initSocket: false,
        function: (d) async {
          DeviceModel newDevice;

          try {
            await Socket.connect(
              d.ip,
              4998,
              timeout: const Duration(seconds: readTimeout),
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

  Future<void> _updateZonesInProject({
    required List<ZoneModel> zones,
    bool getEqualizer = false,
    DeviceModel? device,
  }) async {
    List<ZoneWrapperModel> updatedWrappers;
    List<ZoneGroupModel>? updatedGroups;
    DeviceModel tempDevice = (device ?? currentDevice.value);

    for (final zone in zones) {
      ZoneGroupModel? group;
      final isZoneGrouped = tempDevice.isZoneInGroup(zone);

      if (isZoneGrouped) {
        group = tempDevice.groups.firstWhereOrNull((g) => g.zones.containsZone(zone));
      }

      // final updatedZone = isZoneGrouped ? zone.copyWith(name: group?.getZone(zone.id).name) : zone;
      logger.i("[DBG] UPDATE PROJECT --> ${tempDevice.serialNumber} | ${zone.name}");

      if (isZoneGrouped) {
        final updatedGroup = group?.copyWith(
          zones: group.zones.withReplacement(
            (z) => z.id == zone.id,
            zone,
          ),
        );

        updatedGroups = group == null
            ? null
            : tempDevice.groups.withReplacement(
                (g) => g.id == group!.id,
                updatedGroup!,
              );
      }

      final updatedWrapper = tempDevice.zoneWrappers.firstWhere((w) => w.id == zone.wrapperId).copyWith(zone: zone);

      updatedWrappers = tempDevice.zoneWrappers.withReplacement(
        (w) => w.id == updatedWrapper.id,
        updatedWrapper,
      );

      tempDevice = tempDevice.copyWith(
        zoneWrappers: updatedWrappers,
        groups: updatedGroups,
      );

      _updateCurrentZone(
        zone: zone,
        getEqualizer: getEqualizer,
      );
    }

    if (currentDevice.value.serialNumber == zones.first.deviceSerial) {
      currentDevice.value = tempDevice;
    }

    _updateDeviceInProject(device: tempDevice);
  }

  void _updateDeviceInProject({required DeviceModel device}) {
    final newDevices = currentProject.value.devices.withReplacement(
      (d) => d.serialNumber == device.serialNumber,
      device,
    );

    currentProject.value = currentProject.value.copyWith(devices: newDevices);
    _settings.saveProject(currentProject.value);
  }

  Future<void> _updateCurrentZone({required ZoneModel zone, bool getEqualizer = false}) async {
    if (currentZone.value.deviceSerial == zone.deviceSerial && zone.id == currentZone.value.id) {
      currentZone.value = zone;

      if (getEqualizer) {
        await updateEqualizer();
      }
    }
  }

  Future<void> _updateSignals({
    ProjectModel? project,
    bool allDevices = false,
  }) async {
    currentProject.value = project ?? _getLastProject();
    currentDevice.value = currentProject.value.devices.firstWhere(
      (d) => d.serialNumber == currentDevice.value.serialNumber,
      orElse: () => currentProject.value.devices.first,
    );

    if (currentProject.value.devices.any((d) => d.active)) {
      final zone = currentDevice.value.zones.firstWhere(
        (z) => z.id == currentZone.value.id,
        orElse: () => currentDevice.value.zones.first,
      );

      if (currentDevice.value.isZoneInGroup(zone)) {
        currentZone.value = currentDevice.value.groups.firstWhere((g) => g.zones.containsZone(zone)).asZone;
      } else {
        currentZone.value = zone;
      }

      currentZone.value = currentZone.value.copyWith(
        channel: currentDevice.value.channels.firstWhere(
          (c) => c.id == currentZone.value.channel.id,
          orElse: () => currentDevice.value.channels.first,
        ),
      );

      await _runUpdateData(allDevices: allDevices);
    }
  }

  Future<void> _runUpdateData({required bool allDevices}) async {
    await run(() async {
      try {
        if (allDevices) {
          await _iterateOverDevices(function: (d) => _updateDeviceData(d));
        } else {
          await _updateDeviceData(currentDevice.value);
        }
      } catch (exception) {
        if (exception is StateError && exception.toString().contains("StreamSink")) {
          try {
            await restartSocket(ip: currentDevice.value.ip);

            await _runUpdateData(allDevices: allDevices);
            return;
          } catch (_) {}
        }

        logger.e("Erro ao tentar comunicação com o Multiroom --> $exception");

        _updateDevicesState();
        setError(Exception("Erro ao tentar comunicação com o Multiroom"));
      }
    });
  }

  void _debounceSendCommand(
    String cmd, {
    bool debounce = true,
    required Function() onError,
  }) {
    function() async {
      try {
        final response = await socketSender(cmd);

        if (response.toUpperCase().contains("ERROR")) {
          throw Exception("Retorno do comando com erro");
        }

        currentDevice.value = currentDevice.value.copyWith(active: true);
        _updateDeviceInProject(device: currentDevice.value);
      } catch (exception) {
        logger.e("Erro no comando [$cmd] --> $exception");

        await _updateDevicesState();
        setError(Exception("Erro ao enviar comando"));

        if (exception.toString().contains("Bad state")) {
          await restartSocket(ip: currentDevice.value.ip);
        }

        onError();
      }
    }

    if (debounce) {
      _writeDebouncer(function);
    } else {
      function();
    }
  }

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

    final zones = <ZoneModel>[];

    for (final zoneData in zonesData) {
      final zone = device.zones.firstWhereOrNull((z) => z.id == zoneData.zoneId);

      if (zone == null) {
        continue;
      }

      final channel = device.channels.firstWhere(
        (c) => c.id == zoneData.values.channel,
        orElse: () => device.channels.first,
      );

      zones.add(zone.copyWith(
        active: zoneData.values.power,
        volume: zoneData.values.volume,
        channel: channel,
        balance: zoneData.values.balance,
      ));
    }

    await _updateZonesInProject(
      device: device,
      zones: zones.grouped(device.groups),
      getEqualizer: expandedViewMode.value,
    );
  }

  Future<void> _getDeviceData(DeviceModel device) async {
    // connections.send(
    //   ip: device.ip,
    //   cmd: MrCmdBuilder.getPowerAll(macAddress: device.macAddress),
    // );
    // connections.send(
    //   ip: device.ip,
    //   cmd: MrCmdBuilder.getChannelAll(macAddress: device.macAddress),
    // );
    // connections.send(
    //   ip: device.ip,
    //   cmd: MrCmdBuilder.getVolumeAll(macAddress: device.macAddress),
    // );
    connections.send(
      ip: device.ip,
      cmd: MrCmdBuilder.getBalanceAll(macAddress: device.macAddress),
    );

    // connections.send(
    //   ip: device.ip,
    //   cmd: MrCmdBuilder.getGroup(
    //     macAddress: device.macAddress,
    //     groupId: 1,
    //   ),
    // );
  }

  void dispose() {
    super.baseDispose(key: "$runtimeType");
    mixinDispose();

    projects.value = <ProjectModel>[];

    currentProject.value = currentProject.initialValue;
    currentDevice.value = currentDevice.initialValue;
    currentZone.value = currentZone.initialValue;
    currentEqualizer.value = currentEqualizer.initialValue;
  }
}
