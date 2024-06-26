import 'package:hive/hive.dart';
import 'package:logger/logger.dart';

import '../../extensions/list_extensions.dart';
import '../../models/device_model.dart';
import '../../models/project_model.dart';
import 'settings_contract.dart';

class HiveSettings implements SettingsContract {
  HiveSettings({
    required Box box,
  }) : _box = box;

  final Box _box;
  final _logger = Logger(
    printer: SimplePrinter(
      printTime: true,
      colors: false,
    ),
  );

  @override
  String get technicianAccessHash => "640c5fc8cd23285fd33b66bdf0c4570d";

  @override
  void saveDevice(DeviceModel device) {
    _logger.d("SAVE DEVICE --> PARAM: [$device]}");

    final List<DeviceModel> newList = List.from(devices);
    newList.replaceWhere((d) => d.serialNumber == device.serialNumber, device);
    _box.put("devices", newList);
  }

  @override
  void saveDevices(List<DeviceModel> value) {
    _logger.d("SAVE DEVICES --> PARAM: [$value]}");

    _box.put("devices", value);
  }

  @override
  List<DeviceModel> get devices {
    final data = _box.get("devices", defaultValue: <DeviceModel>[]);

    _logger.d("GET DEVICES --> LENGTH: [${data.length}] | VALUE: $data");

    return List.castFrom<dynamic, DeviceModel>(data);
  }

  @override
  List<ProjectModel> get projects => throw UnimplementedError();

  @override
  void removeDevice(String id) {
    final List<DeviceModel> devices = List.from(this.devices);
    devices.removeWhere((d) => d.serialNumber == id);

    _logger.d("REMOVE DEVICE --> PARAM: [$id] | LENGHT: [${devices.length}] NEW VALUE: $devices");

    _box.put("devices", devices);
  }

  @override
  void removeProject(String id) {}

  @override
  void saveProject(ProjectModel project) {}
}
