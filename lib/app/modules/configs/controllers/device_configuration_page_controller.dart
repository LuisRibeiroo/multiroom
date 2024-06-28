import 'dart:async';

import 'package:collection/collection.dart';
import 'package:signals/signals_flutter.dart';

import '../../../../injector.dart';
import '../../../core/enums/mono_side.dart';
import '../../../core/enums/page_state.dart';
import '../../../core/enums/zone_mode.dart';
import '../../../core/extensions/list_extensions.dart';
import '../../../core/extensions/string_extensions.dart';
import '../../../core/interactor/controllers/base_controller.dart';
import '../../../core/interactor/controllers/socket_mixin.dart';
import '../../../core/interactor/repositories/settings_contract.dart';
import '../../../core/models/device_model.dart';
import '../../../core/models/zone_group_model.dart';
import '../../../core/models/zone_model.dart';
import '../../../core/models/zone_wrapper_model.dart';
import '../../../core/utils/mr_cmd_builder.dart';

class DeviceConfigurationPageController extends BaseController with SocketMixin {
  DeviceConfigurationPageController() : super(InitialState());

  final settings = injector.get<SettingsContract>();

  final deviceName = "".toSignal(debugLabel: "deviceName");
  final device = DeviceModel.empty().toSignal(debugLabel: "device");
  final editingWrapper = ZoneWrapperModel.empty().toSignal(debugLabel: "editingWrapper");
  final editingGroup = ZoneGroupModel.empty().toSignal(debugLabel: "editingGroup");
  final editingZone = ZoneModel.empty().toSignal(debugLabel: "editingZone");
  final isEditingDevice = false.toSignal(debugLabel: "isEditingDevice");
  final isEditingZone = false.toSignal(debugLabel: "isEditingZone");
  final isEditingGroup = false.toSignal(debugLabel: "isEditingGroup");
  final availableZones = listSignal([], debugLabel: "availableZones");
  final maxVolume = 100.toSignal(debugLabel: "maxVolume");

  Future<void> init({required DeviceModel dev}) async {
    device.value = dev;
    deviceName.value = dev.name;

    try {
      await initSocket(ip: dev.ip);
      await run(_updateDeviceData);
    } catch (exception) {
      logger.e(exception);
      if (exception is Exception) {
        setError(exception);
      } else {
        setError(Exception(exception));
      }
    }

    disposables.addAll([
      effect(() {
        final differenceZones =
            device.value.zones.toSet().difference(device.value.groups.expand((g) => g.zones).toSet());

        availableZones.value = differenceZones.toList();
      }),
      effect(() {
        settings.saveDevice(device: device.value);
      })
    ]);
  }

  void toggleEditingDevice() {
    isEditingDevice.value = isEditingDevice.value == false;

    if (isEditingDevice.value == false) {
      device.value = device.peek().copyWith(name: deviceName.value);
    }
  }

  void onTapEditZone(ZoneWrapperModel zone) {
    editingWrapper.value = zone;
  }

  Future<void> onAddZoneToGroup(ZoneGroupModel group, ZoneModel zone) async {
    if (group.zones.contains(zone)) {
      // Show error
    }

    final List<ZoneGroupModel> groups = List.from(device.peek().groups);
    final List<ZoneModel> tempZones = List.from(group.zones);

    groups.replaceWhere((g) => g.id == group.id, group.copyWith(zones: tempZones..add(zone)));
    device.value = device.peek().copyWith(groups: groups);

    await socketSender(
      MrCmdBuilder.setGroup(
        group: group,
        zones: group.zones,
      ),
    );

    // TODO: Check if we need this cmd
    // if (groups[idx].zones.length == 1) {
    //   await socketSender(
    //     MrCmdBuilder.setChannel(
    //       zone: groups[idx].zones.first,
    //       channel: groups[idx].zones.first.channels.first,
    //     ),
    //   );
    // }
  }

  Future<void> onRemoveZoneFromGroup(ZoneGroupModel group, ZoneModel zone) async {
    if (group.zones.contains(zone) == false) {
      return;
    }

    final List<ZoneGroupModel> groups = List.from(device.peek().groups);
    final List<ZoneModel> tempZones = List.from(group.zones);
    final idx = groups.indexOf(group);

    groups[idx] = groups[idx].copyWith(zones: tempZones..remove(zone));
    device.value = device.peek().copyWith(groups: groups);

    await socketSender(
      MrCmdBuilder.setGroup(
        group: groups[idx],
        zones: groups[idx].zones,
      ),
    );
  }

  Future<void> onChangeZoneMode(ZoneWrapperModel wrapper, bool isStereo) async {
    try {
      isEditingZone.value = false;
      editingZone.value = editingZone.initialValue;

      await socketSender(
        MrCmdBuilder.setZoneMode(
          zone: wrapper,
          mode: isStereo ? ZoneMode.stereo : ZoneMode.mono,
        ),
      );

      editingWrapper.value = wrapper.copyWith(mode: isStereo ? ZoneMode.stereo : ZoneMode.mono);

      device.value = device.peek().copyWith(
            zoneWrappers: device.peek().zoneWrappers.map((z) => z.id == wrapper.id ? editingWrapper.value : z).toList(),
          );

      _updateGroupZones(editingWrapper.value);
    } catch (exception) {
      if (exception is Exception) {
        setError(exception);
      } else {
        setError(Exception(exception));
      }
    }
  }

  void onChangeZoneName(ZoneModel zone, String value) {
    if (editingWrapper.value.isStereo) {
      editingWrapper.value = editingWrapper.peek().copyWith(stereoZone: zone.copyWith(name: value));
    } else {
      if (zone.side == MonoSide.left) {
        editingWrapper.value = editingWrapper.peek().copyWith(
              monoZones: editingWrapper.peek().monoZones.copyWith(
                    left: zone.copyWith(name: value),
                  ),
            );
      } else {
        editingWrapper.value = editingWrapper.peek().copyWith(
              monoZones: editingWrapper.peek().monoZones.copyWith(
                    right: zone.copyWith(name: value),
                  ),
            );
      }
    }
  }

  void onChangeGroupName(ZoneGroupModel group, String value) {
    editingGroup.value = editingGroup.value.copyWith(name: value);
  }

  void toggleEditingZone(ZoneWrapperModel wrapper, ZoneModel zone) {
    if (wrapper.id == editingWrapper.value.id && zone.id == editingZone.peek().id) {
      isEditingZone.value = !isEditingZone.peek();
    } else {
      isEditingZone.value = true;
      editingWrapper.value = wrapper;
      editingZone.value = zone;

      return;
    }

    if (isEditingZone.value == false) {
      device.value = device.peek().copyWith(
            zoneWrappers: device
                .peek()
                .zoneWrappers
                .map(
                  (z) => z.id == editingWrapper.peek().id ? editingWrapper.value : z,
                )
                .toList(),
          );

      _updateGroupZoneNames(switch (zone.side) {
        MonoSide.undefined => editingWrapper.peek().stereoZone,
        MonoSide.left => editingWrapper.peek().monoZones.left,
        MonoSide.right => editingWrapper.peek().monoZones.right,
      });

      editingZone.value = editingZone.initialValue;
      editingWrapper.value = editingWrapper.initialValue;
    }
  }

  void toggleEditingGroup(ZoneGroupModel group) {
    if (group.id == editingGroup.peek().id) {
      isEditingGroup.value = !isEditingGroup.peek();
    } else {
      isEditingGroup.value = true;
      editingGroup.value = group;

      return;
    }

    if (isEditingGroup.peek() == false) {
      device.value = device.peek().copyWith(
            groups: device
                .peek()
                .groups
                .map(
                  (z) => z.id == editingGroup.peek().id ? editingGroup.value : z,
                )
                .toList(),
          );

      editingGroup.value = editingGroup.initialValue;
    }
  }

  void onRemoveDevice() {
    settings.removeDevice(projectId: device.peek().projectId, deviceId: device.peek().serialNumber);
  }

  Future<void> onFactoryRestore() async {
    await socketSender(MrCmdBuilder.setDefaultConfigs);

    device.value = DeviceModel.builder(
      projectName: device.value.projectName,
      projectId: device.value.projectId,
      serialNumber: device.value.serialNumber,
      name: device.value.name,
      ip: device.value.ip,
      version: device.value.version,
      type: device.value.type,
    );

    await _updateDeviceData();
  }

  Future<void> onSetMaxVolume(ZoneWrapperModel wrapper, ZoneModel zone) async {
    if (wrapper.isStereo) {
      editingWrapper.value = wrapper.copyWith(stereoZone: zone.copyWith(maxVolume: maxVolume.value));
    } else {
      if (zone.side == MonoSide.left) {
        editingWrapper.value = wrapper.copyWith(
          monoZones: wrapper.monoZones.copyWith(
            left: zone.copyWith(
              maxVolume: maxVolume.value,
            ),
          ),
        );
      } else {
        editingWrapper.value = wrapper.copyWith(
          monoZones: wrapper.monoZones.copyWith(
            right: zone.copyWith(
              maxVolume: maxVolume.value,
            ),
          ),
        );
      }
    }

    device.value = device.peek().copyWith(
          zoneWrappers: device
              .peek()
              .zoneWrappers
              .map(
                (z) => z.id == editingWrapper.peek().id ? editingWrapper.value : z,
              )
              .toList(),
        );

    try {
      await socketSender(MrCmdBuilder.setMaxVolume(
        zone: zone,
        volume: maxVolume.value,
      ));

      maxVolume.value = maxVolume.initialValue;
    } catch (exception) {
      setError(Exception("Erro ao definir volume máximo --> $exception"));
    }
  }

  Future<void> _updateDeviceData() async {
    final configs = await _getDeviceData();

    device.value = device.peek().copyWith(
          zoneWrappers: _parseZones(configs),
        );

    device.value = device.peek().copyWith(
          groups: _parseGroups(configs),
        );
  }

  void _updateGroupZoneNames(ZoneModel zone) {
    for (final group in device.peek().groups) {
      final zoneIndex = group.zones.indexWhere((z) => z.id == zone.id);

      if (zoneIndex != -1) {
        final List<ZoneGroupModel> groups = List.from(device.peek().groups);
        final List<ZoneModel> newZones = List.from(group.zones);
        final idx = groups.indexOf(group);

        newZones[zoneIndex] = zone;
        groups[idx] = groups[idx].copyWith(zones: newZones);
        device.value = device.peek().copyWith(groups: groups);

        break;
      }
    }
  }

  void _updateGroupZones(ZoneWrapperModel wrapper) {
    // final removedZones = groupZones.difference(wrapper.zones.toSet());

    for (final group in device.value.groups) {
      final groupZones = group.zones.toSet();
      final wrapperZones = wrapper.isStereo ? {wrapper.monoZones.left, wrapper.monoZones.right} : {wrapper.stereoZone};

      final newZones = groupZones.intersection(wrapperZones);

      if (newZones.isEmpty) {
        continue;
      }

      final List<ZoneGroupModel> groups = List.from(device.peek().groups);
      final idx = groups.indexOf(group);

      groups[idx] = groups[idx].copyWith(zones: groupZones.difference(wrapperZones).toList());
      device.value = device.peek().copyWith(groups: groups);

      break;
    }
  }

  Future<Map<String, String>> _getDeviceData() async {
    try {
      final configs = MrCmdBuilder.parseConfigs(
        await socketSender(
          MrCmdBuilder.configs,
          longRet: true,
        ),
      );

      return configs;
    } catch (exception) {
      logger.e(exception);
      setError(exception as Exception);

      rethrow;
    }
  }

  List<ZoneWrapperModel> _parseZones(Map<String, String> configs) {
    final modes = configs.entries.where((entry) => entry.key.toUpperCase().startsWith("MODE"));
    final maxVols = configs.entries.where((entry) => entry.key.toUpperCase().startsWith("VOL_MAX"));

    final zonesList = <ZoneWrapperModel>[];

    for (final mode in modes) {
      ZoneWrapperModel wrapper = device.value.zoneWrappers.isEmpty
          ? switch (mode.key) {
              "MODE1" => ZoneWrapperModel.builder(index: 1, name: "Zona 1"),
              "MODE2" => ZoneWrapperModel.builder(index: 2, name: "Zona 2"),
              "MODE3" => ZoneWrapperModel.builder(index: 3, name: "Zona 3"),
              "MODE4" => ZoneWrapperModel.builder(index: 4, name: "Zona 4"),
              "MODE5" => ZoneWrapperModel.builder(index: 5, name: "Zona 5"),
              "MODE6" => ZoneWrapperModel.builder(index: 6, name: "Zona 6"),
              "MODE7" => ZoneWrapperModel.builder(index: 7, name: "Zona 7"),
              "MODE8" => ZoneWrapperModel.builder(index: 8, name: "Zona 8"),
              _ => ZoneWrapperModel.empty(),
            }
          : switch (mode.key) {
              "MODE1" => device.value.zoneWrappers[0], //ZoneWrapperModel.builder(index: 1, name: "Zona 1"),
              "MODE2" => device.value.zoneWrappers[1], //ZoneWrapperModel.builder(index: 2, name: "Zona 2"),
              "MODE3" => device.value.zoneWrappers[2], //ZoneWrapperModel.builder(index: 3, name: "Zona 3"),
              "MODE4" => device.value.zoneWrappers[3], //ZoneWrapperModel.builder(index: 4, name: "Zona 4"),
              "MODE5" => device.value.zoneWrappers[4], //ZoneWrapperModel.builder(index: 5, name: "Zona 5"),
              "MODE6" => device.value.zoneWrappers[5], //ZoneWrapperModel.builder(index: 6, name: "Zona 6"),
              "MODE7" => device.value.zoneWrappers[6], //ZoneWrapperModel.builder(index: 7, name: "Zona 7"),
              "MODE8" => device.value.zoneWrappers[7], //ZoneWrapperModel.builder(index: 8, name: "Zona 8"),
              _ => ZoneWrapperModel.empty(),
            };

      if (wrapper.isEmpty) {
        continue;
      }

      if (mode.value.toUpperCase() == "STEREO") {
        final maxVolume = maxVols.firstWhere(
          (entry) => entry.key.contains(wrapper.id.replaceAll("Z", "")),
          orElse: () => MapEntry(wrapper.id, "100"),
        );

        wrapper = wrapper.copyWith(
          mode: ZoneMode.stereo,
          stereoZone: wrapper.stereoZone.copyWith(
            maxVolume: int.parse(maxVolume.value.numbersOnly),
          ),
        );
      } else {
        final maxVolumeR = maxVols
            .firstWhere(
              (entry) => entry.key.contains(wrapper.id.replaceAll("Z", "")) && entry.key.endsWith("R"),
              orElse: () => MapEntry(wrapper.id, "100"),
            )
            .value;

        final maxVolumeL = maxVols
            .firstWhere(
              (entry) => entry.key.contains(wrapper.id.replaceAll("Z", "")) && entry.key.endsWith("L"),
              orElse: () => MapEntry(wrapper.id, "100"),
            )
            .value;

        wrapper = wrapper.copyWith(
          mode: ZoneMode.mono,
          monoZones: wrapper.monoZones.copyWith(
            right: wrapper.monoZones.right.copyWith(
              maxVolume: int.parse(maxVolumeR.numbersOnly),
            ),
            left: wrapper.monoZones.left.copyWith(
              maxVolume: int.parse(maxVolumeL.numbersOnly),
            ),
          ),
        );
      }

      zonesList.add(wrapper);
    }

    return zonesList;
  }

  List<ZoneGroupModel> _parseGroups(Map<String, String> configs) {
    final grps = configs.entries.where((entry) => entry.key.toUpperCase().startsWith("GRP"));

    final List<ZoneModel> zonesList = List.from(device.peek().zones);
    final zonesMap = <String, ZoneGroupModel>{
      "G1": device.value.groups[0],
      "G2": device.value.groups[1],
      "G3": device.value.groups[2],
    };

    for (final grp in grps) {
      if (grp.value.contains("null")) {
        continue;
      }

      final zone = zonesList.firstWhere((z) => z.id == grp.value);

      switch (grp.key) {
        case _ when grp.key.startsWith("GRP[1]"):
          zonesMap["G1"]!.zones.addIfAbsent(zone);
          break;

        case _ when grp.key.startsWith("GRP[2]"):
          zonesMap["G2"]!.zones.addIfAbsent(zone);
          break;

        case _ when grp.key.startsWith("GRP[3]"):
          zonesMap["G3"]!.zones.addIfAbsent(zone);
          break;
      }
    }

    final groupsList = <ZoneGroupModel>[];

    zonesMap.entries.forEachIndexed((index, entry) {
      groupsList.add(device.value.groups[index].copyWith(zones: entry.value.zones));
    });

    return groupsList;
  }

  @override
  void dispose() {
    super.dispose();
    mixinDispose();

    deviceName.value = deviceName.initialValue;
    device.value = device.initialValue;
    editingWrapper.value = editingWrapper.initialValue;
    editingGroup.value = editingGroup.initialValue;
    editingZone.value = editingZone.initialValue;
    isEditingDevice.value = isEditingDevice.initialValue;
    isEditingZone.value = isEditingZone.initialValue;
    isEditingGroup.value = isEditingGroup.initialValue;
    maxVolume.value = maxVolume.initialValue;

    availableZones.value = <ZoneModel>[];
  }
}
