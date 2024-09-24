import 'package:flutter/material.dart';
import 'package:routefly/routefly.dart';
import 'package:signals/signals_flutter.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../injector.dart';
import '../../../../routes.g.dart';
import '../../../core/extensions/number_extensions.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../../shared/pages/options_bottom_sheet.dart';
import '../../widgets/project_list_card.dart';
import '../controllers/configs_page_controller.dart';
import '../widgets/no_devices_widget.dart';

class ConfigsPage extends StatefulWidget {
  const ConfigsPage({super.key});

  @override
  State<ConfigsPage> createState() => _ConfigsPageState();
}

class _ConfigsPageState extends State<ConfigsPage> {
  final _controller = injector.get<ConfigsPageController>();

  @override
  Widget build(BuildContext context) {
    return Watch(
      (_) => VisibilityDetector(
        key: const ValueKey(ConfigsPage),
        onVisibilityChanged: (info) {
          if (info.visibleFraction == 1) {
            _controller.syncDevices();
          }
        },
        child: LoadingOverlay(
          state: _controller.state,
          child: Scaffold(
            appBar: AppBar(
              leading: Image.asset("assets/logo.png"),
              title: const Text("Configurações"),
              actions: [
                IconButton(
                  onPressed: () => OptionsMenu.showOptionsBottomSheet(context),
                  icon: const Icon(Icons.more_vert_rounded),
                ),
              ],
            ),
            body: Visibility(
              visible: _controller.projects.isEmpty,
              replacement: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: _controller.projects.length,
                separatorBuilder: (_, __) => 18.asSpace,
                itemBuilder: (_, index) => Watch(
                  (_) => ProjectListCard(
                    project: _controller.projects[index],
                    deviceAvailabilityMap: const {},
                    showAvailability: false,
                    onTapConfigDevice: (d) => OptionsMenu.showTechBottomSheet(context, device: d),
                    onTapRemoveProject: _controller.removeProject,
                  ),
                ),
              ),
              child: const NoDevicesWidget(),
            ),
            floatingActionButton: _controller.projects.isEmpty
                ? FloatingActionButton.extended(
                    icon: const Icon(Icons.settings_input_antenna_rounded),
                    label: const Text("Iniciar configuração"),
                    onPressed: () => OptionsMenu.showTechBottomSheet(context),
                  )
                : FloatingActionButton.extended(
                    icon: const Icon(Icons.check_rounded),
                    label: const Text("Finalizar configurações"),
                    onPressed: () {
                      Routefly.replace(routePaths.modules.home.pages.home);
                      Routefly.pushNavigate(routePaths.modules.home.pages.home);
                    },
                  ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }
}
