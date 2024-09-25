import 'package:hive/hive.dart';

import '../../extensions/list_extensions.dart';
import '../../models/device_model.dart';
import '../../models/project_model.dart';
import 'settings_contract.dart';

class HiveSettings implements SettingsContract {
  HiveSettings({
    required Box box,
  }) : _box = box;

  Box _box;
  // final _logger = Logger(
  //   printer: SimplePrinter(
  //     printTime: true,
  //     colors: false,
  //   ),
  // );

  @override
  void updateReference(dynamic newRef) => _box = newRef as Box;

  @override
  String get technicianAccessHash => "640c5fc8cd23285fd33b66bdf0c4570d";

  @override
  void saveDevice({required DeviceModel device}) {
    // _logger.d("SAVE DEVICE --> PARAM: [$device]}");

    ProjectModel updatedProj = projects.firstWhere(
      (p) => p.id == device.projectId,
      orElse: () => projects.first,
    );

    final updatedDevices = updatedProj.devices;
    updatedDevices.replaceWhere((d) => d.serialNumber == device.serialNumber, device);

    updatedProj = updatedProj.copyWith(devices: updatedDevices);

    saveProject(updatedProj);
  }

  @override
  void removeDevice({required String projectId, required String deviceId}) {
    ProjectModel updatedProj = projects.firstWhere((p) => p.id == projectId);
    final updatedDevices = updatedProj.devices;
    updatedDevices.removeWhere((d) => d.serialNumber == deviceId);

    updatedProj = updatedProj.copyWith(devices: updatedDevices);

    // _logger.d("REMOVE DEVICE --> PARAM: [$deviceId] | LENGHT: [${updatedDevices.length}] NEW VALUE: $updatedDevices");

    saveProject(updatedProj);
  }

  @override
  List<ProjectModel> get projects {
    final data = _box.get("projects", defaultValue: <ProjectModel>[]);

    // _logger.d("GET PROJECTS --> LENGTH: [${data.length}] | VALUE: $data");

    return List.castFrom<dynamic, ProjectModel>(data);
  }

  @override
  void saveProject(ProjectModel project) {
    // _logger.d("SAVE PROJECT --> PARAM: [$project]}");

    final List<ProjectModel> newList = List.from(projects);
    newList.replaceWhere((d) => d.id == project.id, project);
    _box.put("projects", newList);
  }

  @override
  void saveProjects(List<ProjectModel> value) {
    // _logger.d("SAVE PROJECTS --> LENGHT: ${value.length} | PARAM: [$value]}");

    _box.put("projects", value);
  }

  @override
  void removeProject(String id) {
    final List<ProjectModel> projs = List.from(projects);
    projs.removeWhere((d) => d.id == id);

    // _logger.d("REMOVE PROJECT --> PARAM: [$id] | LENGHT: [${projs.length}] NEW VALUE: $projs");

    _box.put("projects", projs);
  }

  @override
  bool get expandedViewMode => _box.get("expandedViewMode", defaultValue: false);

  @override
  set expandedViewMode(bool value) => _box.put("expandedViewMode", value);

  @override
  String get lastProjectId => _box.get("lastProjectId", defaultValue: "");

  @override
  set lastProjectId(String value) => _box.put("lastProjectId", value);
}
