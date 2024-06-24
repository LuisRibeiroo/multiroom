import 'dart:async';

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

  Future<void> init({required DeviceModel dev}) async {
    device.value = dev;
    deviceName.value = dev.name;

    try {
      // await initSocket(ip: dev.ip);
    } catch (exception) {
      logger.e(exception);
      setError(exception as Exception);
    }

    final configs = await _getDeviceData();

    // device.value = device.value.copyWith(
    //   zoneWrappers: _parseZones(configs),
    // );

    // device.value = device.value.copyWith(
    //   groups: _parseGroups(configs),
    // );

    disposables.addAll([
      effect(
        () {
          settings.saveDevice(device.value);
        },
      ),
      effect(() {
        availableZones.value = device.value.zones
            .where((zone) => device.value.groups.map((g) => g.zones.contains(zone)).every((v) => !v))
            .toList();
      }),
    ]);
  }

  void toggleEditingDevice() {
    isEditingDevice.value = isEditingDevice.value == false;

    if (isEditingDevice.value == false) {
      device.value = device.value.copyWith(name: deviceName.value);
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

    final idx = groups.indexOf(group);
    groups[idx] = groups[idx].copyWith(zones: tempZones..add(zone));
    device.value = device.value.copyWith(groups: groups);

    await socketSender(
      MrCmdBuilder.setGroup(
        group: groups[idx],
        zones: groups[idx].zones,
      ),
    );
  }

  Future<void> onRemoveZoneFromGroup(ZoneGroupModel group, ZoneModel zone) async {
    if (group.zones.contains(zone) == false) {
      return;
    }

    final List<ZoneGroupModel> groups = List.from(device.peek().groups);
    final List<ZoneModel> tempZones = List.from(group.zones);
    final idx = groups.indexOf(group);

    groups[idx] = groups[idx].copyWith(zones: tempZones..remove(zone));
    device.value = device.value.copyWith(groups: groups);

    await socketSender(
      MrCmdBuilder.setGroup(
        group: groups[idx],
        zones: groups[idx].zones,
      ),
    );
  }

  Future<void> onChangeZoneMode(ZoneWrapperModel zone, bool isStereo) async {
    try {
      isEditingZone.value = false;
      editingZone.value = editingZone.initialValue;

      await _readCommand(
        MrCmdBuilder.setZoneMode(
          zone: zone,
          mode: isStereo ? ZoneMode.stereo : ZoneMode.mono,
        ),
      );

      editingWrapper.value = zone.copyWith(mode: isStereo ? ZoneMode.stereo : ZoneMode.mono);

      device.value = device.value.copyWith(
          zoneWrappers: device.value.zoneWrappers.map((z) => z.id == zone.id ? editingWrapper.value : z).toList());
    } catch (exception) {
      setError(exception as Exception);
    }
  }

  void onChangeZoneName(ZoneModel zone, String value) {
    if (editingWrapper.value.isStereo) {
      editingWrapper.value = editingWrapper.value.copyWith(stereoZone: zone.copyWith(name: value));
    } else {
      if (zone.side == MonoSide.left) {
        editingWrapper.value = editingWrapper.value
            .copyWith(monoZones: (left: zone.copyWith(name: value), right: editingWrapper.value.monoZones.right));
      } else {
        editingWrapper.value = editingWrapper.value
            .copyWith(monoZones: (right: zone.copyWith(name: value), left: editingWrapper.value.monoZones.left));
      }
    }
  }

  void onChangeGroupName(ZoneGroupModel group, String value) {
    editingGroup.value = editingGroup.value.copyWith(name: value);
  }

  void toggleEditingZone(ZoneWrapperModel wrapper, ZoneModel zone) {
    if (wrapper.id == editingWrapper.value.id && zone.id == editingZone.value.id) {
      isEditingZone.value = !isEditingZone.value;
    } else {
      isEditingZone.value = true;
      editingWrapper.value = wrapper;
      editingZone.value = zone;

      return;
    }

    if (isEditingZone.value == false) {
      device.value = device.value.copyWith(
        zoneWrappers: device.value.zoneWrappers
            .map(
              (z) => z.id == editingWrapper.value.id ? editingWrapper.value : z,
            )
            .toList(),
      );

      _updateGroupZones(switch (zone.side) {
        MonoSide.undefined => editingWrapper.value.stereoZone,
        MonoSide.left => editingWrapper.value.monoZones.left,
        MonoSide.right => editingWrapper.value.monoZones.right,
      });

      editingZone.value = editingZone.initialValue;
      editingWrapper.value = editingWrapper.initialValue;
    }
  }

  void toggleEditingGroup(ZoneGroupModel group) {
    if (group.id == editingGroup.value.id) {
      isEditingGroup.value = !isEditingGroup.value;
    } else {
      isEditingGroup.value = true;
      editingGroup.value = group;

      return;
    }

    if (isEditingGroup.value == false) {
      device.value = device.value.copyWith(
        groups: device.value.groups
            .map(
              (z) => z.id == editingGroup.value.id ? editingGroup.value : z,
            )
            .toList(),
      );

      editingGroup.value = editingGroup.initialValue;
    }
  }

  void removeDevice() {
    settings.removeDevice(device.value.serialNumber);
  }

  void _updateGroupZones(ZoneModel zone) {
    // if (availableZones.contains(zone)) {
    //   return;
    // }

    for (final group in device.peek().groups) {
      final zoneIndex = group.zones.indexWhere((z) => z.id == zone.id);

      if (zoneIndex != -1) {
        final List<ZoneGroupModel> groups = List.from(device.peek().groups);
        final List<ZoneModel> newZones = List.from(group.zones);
        final idx = groups.indexOf(group);

        newZones[zoneIndex] = zone;
        groups[idx] = groups[idx].copyWith(zones: newZones);
        device.value = device.value.copyWith(groups: groups);

        break;
      }
    }
  }

  Future<void> _readCommand(String cmd) async {
    final response = MrCmdBuilder.parseResponse(await socketSender(cmd));

    if (response.contains("OK") == false) {
      throw Exception("Erro ao enviar comando --> CMD: [$cmd] | RESPONSE: [$response]");
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

    final zonesList = <ZoneWrapperModel>[];

    for (final mode in modes) {
      ZoneWrapperModel zone = switch (mode.key) {
        "MODE1" => ZoneWrapperModel.builder(index: 1, name: "Zona 1"),
        "MODE2" => ZoneWrapperModel.builder(index: 2, name: "Zona 2"),
        "MODE3" => ZoneWrapperModel.builder(index: 3, name: "Zona 3"),
        "MODE4" => ZoneWrapperModel.builder(index: 4, name: "Zona 4"),
        "MODE5" => ZoneWrapperModel.builder(index: 5, name: "Zona 5"),
        "MODE6" => ZoneWrapperModel.builder(index: 6, name: "Zona 6"),
        "MODE7" => ZoneWrapperModel.builder(index: 7, name: "Zona 7"),
        "MODE8" => ZoneWrapperModel.builder(index: 8, name: "Zona 8"),
        _ => ZoneWrapperModel.empty(),
      };

      if (zone.isEmpty) {
        continue;
      }

      if (mode.value.toUpperCase() == "STEREO") {
        zone = zone.copyWith(mode: ZoneMode.stereo);
      } else {
        zone = zone.copyWith(mode: ZoneMode.mono);
      }

      zonesList.add(zone);
    }

    return zonesList;
  }

  List<ZoneGroupModel> _parseGroups(Map<String, String> configs) {
    final grps = configs.entries.where((entry) => entry.key.toUpperCase().startsWith("GRP"));

    final List<ZoneModel> zonesList = List.from(device.peek().zones);
    final zonesMap = <String, List<ZoneModel>>{
      "G1": [],
      "G2": [],
      "G3": [],
    };

    for (final grp in grps) {
      if (grp.value.contains("null")) {
        continue;
      }

      final zone = zonesList.firstWhere((z) => z.id == grp.value);

      switch (grp.key) {
        case _ when grp.key.startsWith("GRP[1]"):
          zonesMap["G1"].addIfAbsent(zone);
          break;

        case _ when grp.key.startsWith("GRP[2]"):
          zonesMap["G2"].addIfAbsent(zone);
          break;

        case _ when grp.key.startsWith("GRP[3]"):
          zonesMap["G3"].addIfAbsent(zone);
          break;
      }
    }

    final groupsList = <ZoneGroupModel>[];

    for (final entry in zonesMap.entries) {
      groupsList.add(ZoneGroupModel(
        id: entry.key,
        name: "Grupo ${entry.key.numbersOnly}",
        zones: entry.value,
      ));
    }

    return groupsList;
  }

  @override
  void dispose() {
    super.dispose();
    mixinDispose();

    deviceName.value = deviceName.initialValue;
    device.value = device.initialValue;
    editingWrapper.value = editingWrapper.initialValue;
    editingZone.value = editingZone.initialValue;
    isEditingDevice.value = isEditingDevice.initialValue;
    isEditingZone.value = isEditingZone.initialValue;
    isEditingGroup.value = isEditingGroup.initialValue;

    availableZones.value = <ZoneModel>[];
  }
}
