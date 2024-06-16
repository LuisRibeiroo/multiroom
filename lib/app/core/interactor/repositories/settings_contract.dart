import '../../models/device_model.dart';

abstract class SettingsContract {
  String get technicianAccessHash;

  List<DeviceModel> get devices;
  void saveDevice(DeviceModel device);
  void saveDevices(List<DeviceModel> value);
  void removeDevice(String id);
}
