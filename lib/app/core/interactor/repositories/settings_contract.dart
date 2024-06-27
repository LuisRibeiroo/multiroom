import '../../models/project_model.dart';

import '../../models/device_model.dart';

abstract class SettingsContract {
  String get technicianAccessHash;

  List<ProjectModel> get projects;
  void saveProject(ProjectModel project);
  void saveProjects(List<ProjectModel> value);
  void removeProject(String id);

  List<DeviceModel> get devices;
  void saveDevice(DeviceModel device);
  void saveDevices(List<DeviceModel> value);
  void removeDevice({required String projectId, required String deviceId});
}
