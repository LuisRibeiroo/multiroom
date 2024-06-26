import 'package:flutter/material.dart';
import 'package:routefly/routefly.dart';
import 'package:signals/signals_flutter.dart';

import '../../../../injector.dart';
import '../../../../routes.g.dart';
import '../../../core/extensions/build_context_extensions.dart';
import '../../../core/models/device_model.dart';
import '../../configs/pages/configs_page.dart';
import '../controllers/options_bottom_sheet_controller.dart';

class OptionsMenu {
  static Future<T?> showOptionsBottomSheet<T>(BuildContext context) {
    return context.showCustomModalBottomSheet(
      child: Column(
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
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text("Sobre"),
            onTap: () {},
          ),
        ],
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
