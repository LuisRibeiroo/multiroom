import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../extensions/iterable_extensions.dart';
import '../../models/device_model.dart';
import 'settings_contract.dart';

final class SharedPrefsSettings implements SettingsContract {
  const SharedPrefsSettings({
    required SharedPreferences prefs,
  }) : _prefs = prefs;

  final SharedPreferences _prefs;

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

    _prefs.setStringList("devices", jsonDevices).ignore();
  }

  @override
  void saveDevices(List<DeviceModel> value) {
    final jsonDevices = value.map((d) => jsonEncode(d.toMap())).toList();

    _prefs.setStringList("devices", jsonDevices).ignore();
  }

  @override
  void removeDevice(String id) {
    final currentList = devices;
    final index = currentList.indexWhere((d) => d.serialNumber == id);

    if (index != -1) {
      currentList.removeAt(index);

      final jsonDevices = currentList.map((d) => jsonEncode(d.toMap())).toList();

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

    return list;
  }
}
