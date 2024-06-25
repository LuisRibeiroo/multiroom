import 'package:multiroom/app/core/models/project_model.dart';

import '../../models/device_model.dart';

abstract class SettingsContract {
  String get technicianAccessHash;

  List<ProjectModel> get projects;
  void saveProject(ProjectModel project);
  void removeProject(String id);

  List<DeviceModel> get devices;
  void saveDevice(DeviceModel device);
  void saveDevices(List<DeviceModel> value);
  void removeDevice(String id);
}
