import '../../models/project_model.dart';

import '../../models/device_model.dart';

abstract class SettingsContract {
  String get technicianAccessHash;
  List<ProjectModel> get projects;
  bool get expandedViewMode;
  set expandedViewMode(bool value);
  String get lastProjectId;
  set lastProjectId(String value);
  List<DeviceModel> get devices;

  void updateReference(dynamic newRef);
  void saveProject(ProjectModel project);
  void saveProjects(List<ProjectModel> value);
  void removeProject(String id);

  void saveDevice({required DeviceModel device});
  void removeDevice({required String projectId, required String deviceId});
}
