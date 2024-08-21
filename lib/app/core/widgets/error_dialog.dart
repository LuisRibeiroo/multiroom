import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:toastification/toastification.dart';

import '../../../injector.dart';
import '../../modules/widgets/about_bottom_sheet.dart';
import '../enums/page_state.dart';
import '../extensions/build_context_extensions.dart';
import '../extensions/number_extensions.dart';
import '../interactor/controllers/error_dialog_controller.dart';
import 'app_button.dart';

class ErrorDialog {
  static Future<void> show({
    required BuildContext context,
    required Signal<PageState> pageState,
    required String currentIp,
    Function()? onSuccess,
  }) async {
    final controller = injector.get<ErrorDialogController>();

    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_rounded,
                    color: context.colorScheme.error,
                  ),
                  12.asSpace,
                  Text(
                    "Erro de comunicação com o Multiroom",
                    style: context.textTheme.titleMedium,
                  ),
                ],
              ),
              24.asSpace,
              Text(
                "Verifique se o dispositivo está ligado e conectado corretamente à rede.",
                style: context.textTheme.bodyMedium,
                textAlign: TextAlign.justify,
              ),
              Text(
                "Caso o problema persista, entre em contato com o suporte técnico.",
                style: context.textTheme.bodyMedium,
                textAlign: TextAlign.justify,
              ),
              32.asSpace,
              Row(
                children: [
                  Flexible(
                    child: AppButton(
                      type: ButtonType.secondary,
                      text: "Suporte",
                      onPressed: () {
                        Navigator.of(context).pop();

                        context.showCustomModalBottomSheet(
                          child: const AboutBottomSheet(),
                        );
                      },
                    ),
                  ),
                  24.asSpace,
                  Expanded(
                    child: AppButton(
                      text: "Testar comunicação",
                      onPressed: () async {
                        Navigator.of(context).pop();

                        if (await controller.checkDeviceAvailability(
                          pageState: pageState,
                          currentIp: currentIp,
                        )) {
                          onSuccess?.call();

                          toastification.show(
                            title: const Text("Dispositivo OK!"),
                            autoCloseDuration: const Duration(seconds: 2),
                            style: ToastificationStyle.minimal,
                            type: ToastificationType.success,
                          );
                        } else {
                          if (context.mounted) {
                            ErrorDialog.show(
                              context: context,
                              pageState: pageState,
                              currentIp: currentIp,
                              onSuccess: onSuccess,
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
