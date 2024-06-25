import 'package:flutter/material.dart';
import 'package:routefly/routefly.dart';

import '../../../core/extensions/build_context_extensions.dart';
import '../../../core/extensions/number_extensions.dart';
import '../../../core/widgets/app_button.dart';

class DeleteDeviceConfirmBottomSheet extends StatelessWidget {
  const DeleteDeviceConfirmBottomSheet({
    super.key,
    required this.deviceName,
    required this.onConfirm,
  });

  final String deviceName;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Tem certeza que deseja remover o dispositivo \"$deviceName\"?",
            style: context.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          24.asSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                child: AppButton(
                  type: ButtonType.secondary,
                  text: "Cancelar",
                  onPressed: () {
                    Routefly.pop(context);
                  },
                ),
              ),
              24.asSpace,
              Flexible(
                child: AppButton(
                  text: "Sim",
                  onPressed: () {
                    onConfirm();

                    Routefly.pop(context);
                    Routefly.pop(context);
                  },
                ),
              ),
            ],
          ),
          24.asSpace,
        ],
      ),
    );
  }
}
