import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:routefly/routefly.dart';
import 'package:signals/signals_flutter.dart';

import '../../../../injector.dart';
import '../../../../routes.g.dart';
import '../../../core/enums/page_state.dart';
import '../../../core/extensions/build_context_extensions.dart';
import '../../../core/models/device_model.dart';
import '../../../core/utils/platform_checker.dart';
import '../../widgets/about_bottom_sheet.dart';
import '../../widgets/factory_restore_confirmation_bottom_sheet.dart';
import '../controllers/options_bottom_sheet_controller.dart';
import '../widgets/share_dialog.dart';
import 'tech_access_bottom_sheet.dart';

class OptionsMenu extends StatefulWidget {
  const OptionsMenu({
    super.key,
    required this.pageState,
    this.onFactoryRestore,
  });

  final Signal<PageState> pageState;
  final Function()? onFactoryRestore;

  @override
  State<OptionsMenu> createState() => _OptionsMenuState();
}

class _OptionsMenuState extends State<OptionsMenu> {
  final controller = injector.get<OptionsBottomSheetController>();

  @override
  Widget build(BuildContext context) {
    return Watch(
      (_) => Drawer(
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Image.asset("assets/logo_completo.png"),
                ),
              ),
              const Divider(
                indent: 12,
                endIndent: 12,
              ),
              Visibility(
                visible: controller.showTechAccessOption.value,
                child: ListTile(
                  leading: const Icon(Icons.settings_rounded),
                  title: const Text("Acesso Técnico"),
                  onTap: () => Options.showTechBottomSheet(context),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.qr_code_scanner_rounded),
                title: const Text("Importar projeto"),
                onTap: () async {
                  Routefly.pop(context);

                  if (PlatformChecker.isMobile) {
                    if (await Permission.camera.request().isGranted) {
                      Routefly.pushNavigate(routePaths.modules.shared.pages.importData);
                    }
                  } else {
                    Routefly.pushNavigate(routePaths.modules.shared.pages.importData);
                  }
                },
              ),
              Visibility(
                visible: controller.showShareOption.value,
                child: ListTile(
                  leading: const Icon(Icons.qr_code_rounded),
                  title: const Text("Compartilhar"),
                  onTap: () async {
                    final projectAddress = await controller.onShareProject(pageState: widget.pageState);

                    if (context.mounted) {
                      Routefly.pop(context);

                      showDialog(
                        context: context,
                        builder: (_) => ShareDialog(projectAddress: projectAddress),
                      );
                    }
                  },
                ),
              ),
              Visibility(
                visible: widget.onFactoryRestore != null,
                child: ListTile(
                  leading: const Icon(Icons.restore_rounded),
                  title: const Text("Restaurar configurações de fábrica"),
                  onTap: () {
                    context.showCustomModalBottomSheet(
                      isScrollControlled: false,
                      child: FactoryRestoreConfirmationBottomSheet(
                        onConfirm: () {
                          widget.onFactoryRestore?.call();
                          Scaffold.of(context).closeDrawer();
                        },
                      ),
                    );
                  },
                ),
              ),
              Center(
                child: AnimatedSize(
                  duration: Durations.short1,
                  child: widget.pageState.value is LoadingState
                      ? const CircularProgressIndicator()
                      : const SizedBox.shrink(),
                ),
              ),
              const Spacer(),
              ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: const Text("Sobre"),
                onTap: () {
                  context.showCustomModalBottomSheet(
                    child: const AboutBottomSheet(),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24, bottom: 24.0, top: 12),
                child: FloatingActionButton.small(
                  key: const ValueKey("close_drawer"),
                  onPressed: Scaffold.of(context).closeDrawer,
                  child: const Icon(Icons.arrow_back_rounded),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Options {
  @Deprecated("Remove this if we don't need it")
  static Future<T?> showOptionsBottomSheet<T>(
    BuildContext context, {
    Signal<PageState>? state,
  }) {
    final controller = injector.get<OptionsBottomSheetController>();

    return context.showCustomModalBottomSheet(
      child: Watch(
        (_) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Visibility(
              visible: controller.showTechAccessOption.value,
              child: ListTile(
                leading: const Icon(Icons.settings_rounded),
                title: const Text("Acesso Técnico"),
                onTap: () async {
                  Routefly.pop(context);

                  return await showTechBottomSheet(context);
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner_rounded),
              title: const Text("Importar projeto"),
              onTap: () async {
                Routefly.pop(context);

                if (PlatformChecker.isMobile) {
                  if (await Permission.camera.request().isGranted) {
                    Routefly.pushNavigate(routePaths.modules.shared.pages.importData);
                  }
                } else {
                  Routefly.pushNavigate(routePaths.modules.shared.pages.importData);
                }
              },
            ),
            Visibility(
              visible: controller.showShareOption.value,
              child: ListTile(
                leading: const Icon(Icons.qr_code_rounded),
                title: const Text("Compartilhar"),
                onTap: () async {
                  Routefly.pop(context);

                  final projectAddress = await controller.onShareProject(pageState: state!);

                  if (context.mounted) {
                    showDialog(
                      context: context,
                      builder: (_) => ShareDialog(projectAddress: projectAddress),
                    );
                  }
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: const Text("Sobre"),
              onTap: () {
                Routefly.pop(context);

                context.showCustomModalBottomSheet(
                  child: const AboutBottomSheet(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  static Future<T?> showTechBottomSheet<T>(BuildContext context, {DeviceModel? device}) {
    final controller = injector.get<OptionsBottomSheetController>();

    return context.showCustomModalBottomSheet(
      child: SafeArea(
        child: Watch(
          (_) => TechAccessBottomSheet(
            errorMessage: controller.errorMessage.value,
            onChangePassword: controller.password.set,
            isPasswordVisible: controller.isPasswordVisible.value,
            onTogglePasswordVisible: controller.onTogglePassword,
            onTapAccess: () {
              final valid = controller.onTapAccess();

              if (valid) {
                if (Scaffold.of(context).isDrawerOpen) {
                  Scaffold.of(context).closeDrawer();
                }

                controller.errorMessage.value = "";

                Routefly.pop(context);
                Routefly.pushNavigate(routePaths.modules.scanner.pages.scanner);
              }
            },
            onTapConfigDevice: device == null
                ? null
                : () {
                    Routefly.pop(context);

                    Routefly.pushNavigate(
                      routePaths.modules.configs.pages.deviceConfiguration,
                      arguments: device,
                    );
                  },
          ),
        ),
      ),
    );
  }
}
