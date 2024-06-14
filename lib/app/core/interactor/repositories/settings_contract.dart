import 'package:multiroom/app/core/models/device_model.dart';

abstract class SettingsContract {
  bool get darkMode;
  set darkMode(bool v);

  List<DeviceModel> get devices;
  void saveDevice(DeviceModel device);
  void saveDevices(List<DeviceModel> value);
}
