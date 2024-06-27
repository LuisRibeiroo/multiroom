import 'package:flutter/material.dart';
import 'package:routefly/routefly.dart';

import '../../core/extensions/build_context_extensions.dart';
import '../../core/extensions/number_extensions.dart';
import '../../core/widgets/app_button.dart';

class FactoryRestoreConfirmationBottomSheet extends StatelessWidget {
  const FactoryRestoreConfirmationBottomSheet({
    super.key,
    required this.onConfirm,
  });

  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Tem certeza que deseja restaurar o dispositivo para os parâmetros de fábrica?",
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
