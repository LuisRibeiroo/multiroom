import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../extensions/iterable_extensions.dart';
import '../../models/device_model.dart';
import 'settings_contract.dart';

final class SharedPrefsSettings implements SettingsContract {
  SharedPrefsSettings({
    required SharedPreferences prefs,
  }) : _prefs = prefs;

  final SharedPreferences _prefs;
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
    final currentList = devices;
    final index = currentList.indexWhere((d) => d.serialNumber == device.serialNumber);

    if (index == -1) {
      currentList.add(device);
    } else {
      currentList[index] = device;
    }

    final jsonDevices = currentList.map((d) => jsonEncode(d.toMap())).toList();

    _logger.d("SAVE DEVICE --> PARAM: [$device] | NEW VALUE: $jsonDevices");
    _prefs.setStringList("devices", jsonDevices).ignore();
  }

  @override
  void saveDevices(List<DeviceModel> value) {
    final jsonDevices = value.map((d) => jsonEncode(d.toMap())).toList();

    _logger.d("SAVE DEVICES --> PARAM: [$value] | NEW VALUE: $jsonDevices");
    _prefs.setStringList("devices", jsonDevices).ignore();
  }

  @override
  void removeDevice(String id) {
    final currentList = devices;
    final index = currentList.indexWhere((d) => d.serialNumber == id);

    if (index != -1) {
      currentList.removeAt(index);

      final jsonDevices = currentList.map((d) => jsonEncode(d.toMap())).toList();

      _logger.d("REMOVE DEVICE --> PARAM: [$id] | NEW VALUE: $jsonDevices");
      _prefs.setStringList("devices", jsonDevices).ignore();
    }
  }

  @override
  List<DeviceModel> get devices {
    final jsonDevices = _prefs.getStringList("devices");

    if (jsonDevices.isNullOrEmpty) {
      return <DeviceModel>[];
    }

    final list = jsonDevices!.map((d) => DeviceModel.fromMap(jsonDecode(d))).toList();
    _logger.d("GET DEVICES --> VALUE: $jsonDevices");

    return list;
  }
}
