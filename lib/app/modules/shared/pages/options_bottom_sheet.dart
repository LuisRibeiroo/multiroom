import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:routefly/routefly.dart';
import 'package:signals/signals_flutter.dart';

import '../../../../injector.dart';
import '../../../../routes.g.dart';
import '../../../core/enums/page_state.dart';
import '../../../core/extensions/build_context_extensions.dart';
import '../../../core/models/device_model.dart';
import '../../configs/pages/configs_page.dart';
import '../../widgets/about_bottom_sheet.dart';
import '../controllers/options_bottom_sheet_controller.dart';

class OptionsMenu {
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
            ListTile(
              leading: const Icon(Icons.settings_rounded),
              title: const Text("Acesso Técnico"),
              onTap: () async {
                Routefly.pop(context);

                return await showTechBottomSheet(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner_rounded),
              title: const Text("Importar projeto"),
              onTap: () {
                // Routefly.pop(context);

                // context.showCustomModalBottomSheet(
                //   child: const AboutBottomSheet(),
                // );
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
                      builder: (_) => Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: QrImageView(
                              data: projectAddress,
                              size: 300,
                              padding: const EdgeInsets.all(12),
                              backgroundColor: context.colorScheme.primary,
                              embeddedImage: const AssetImage("assets/logo.png"),
                              embeddedImageStyle: QrEmbeddedImageStyle(
                                size: const Size(101, 56),
                                color: context.colorScheme.inversePrimary,
                              ),
                              eyeStyle: QrEyeStyle(
                                color: context.colorScheme.surface,
                                eyeShape: QrEyeShape.circle,
                              ),
                              dataModuleStyle: QrDataModuleStyle(
                                color: context.colorScheme.surface,
                                dataModuleShape: QrDataModuleShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
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
