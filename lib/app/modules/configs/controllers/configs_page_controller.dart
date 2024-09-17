import 'package:signals/signals_flutter.dart';

import '../../../../injector.dart';
import '../../../core/enums/page_state.dart';
import '../../../core/interactor/controllers/base_controller.dart';
import '../../../core/interactor/repositories/settings_contract.dart';
import '../../../core/models/project_model.dart';

class ConfigsPageController extends BaseController {
  ConfigsPageController() : super(InitialState()) {
    projects.value = settings.projects;
  }

  final settings = injector.get<SettingsContract>();

  final projects = listSignal<ProjectModel>([], debugLabel: "projects");

  void syncDevices() {
    projects.value = settings.projects;
  }

  void removeProject(ProjectModel project) {
    settings.removeProject(project.id);
    projects.value = settings.projects;
  }

  @override
  void dispose() {
    super.dispose();

    projects.value = <ProjectModel>[];
  }
}
