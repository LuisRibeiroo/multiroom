import 'dart:async';

import 'package:signals/signals_flutter.dart';

import '../../../../../injector.dart';
import '../../../../core/enums/mono_side.dart';
import '../../../../core/enums/page_state.dart';
import '../../../../core/enums/zone_mode.dart';
import '../../../../core/interactor/controllers/base_controller.dart';
import '../../../../core/interactor/controllers/socket_mixin.dart';
import '../../../../core/interactor/repositories/settings_contract.dart';
import '../../../../core/models/device_model.dart';
import '../../../../core/models/zone_model.dart';
import '../../../../core/models/zone_wrapper_model.dart';
import '../../../../core/utils/mr_cmd_builder.dart';

class DeviceConfigurationPageController extends BaseController with SocketMixin {
  DeviceConfigurationPageController() : super(InitialState());

  final settings = injector.get<SettingsContract>();

  final deviceName = "".toSignal(debugLabel: "deviceName");
  final device = DeviceModel.empty().toSignal(debugLabel: "device");
  final editingWrapper = ZoneWrapperModel.empty().toSignal(debugLabel: "editingWrapper");
  final editingZone = ZoneModel.empty().toSignal(debugLabel: "editingZone");
  final isEditingDevice = false.toSignal(debugLabel: "isEditingDevice");
  final isEditingZone = false.toSignal(debugLabel: "isEditingZone");

  Future<void> init({required DeviceModel dev}) async {
    device.value = dev;
    deviceName.value = dev.name;

    try {
      await initSocket(ip: dev.ip);
    } catch (exception) {
      logger.e(exception);
      setError(exception as Exception);
    }

    final configs = await _getDeviceData();
    device.value = device.value.copyWith(zones: _parseZones(configs));

    disposables.add(
      effect(
        () {
          settings.saveDevice(device.value);
        },
      ),
    );
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

      device.value = device.value
          .copyWith(zones: device.value.zones.map((z) => z.id == zone.id ? editingWrapper.value : z).toList());
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
        zones: device.value.zones
            .map(
              (z) => z.id == editingWrapper.value.id ? editingWrapper.value : z,
            )
            .toList(),
      );

      editingZone.value = editingZone.initialValue;
      editingWrapper.value = editingWrapper.initialValue;
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
  }
}
