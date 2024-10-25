import 'package:flutter/material.dart';
import 'package:multiroom/app/core/extensions/build_context_extensions.dart';
import 'package:multiroom/app/core/extensions/number_extensions.dart';
import 'package:multiroom/app/core/widgets/app_button.dart';
import 'package:routefly/routefly.dart';

class DisableAllZonesBottomSheet extends StatelessWidget {
  const DisableAllZonesBottomSheet({super.key, required this.onConfirm});

  final Function() onConfirm;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Tem certeza que deseja desativar todas as Zonas do Projeto?",
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
                    Routefly.pop(context);

                    onConfirm();
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
