import 'package:flutter/material.dart';
import 'package:multiroom/app/core/extensions/build_context_extensions.dart';
import 'package:multiroom/app/core/extensions/number_extensions.dart';
import 'package:multiroom/app/core/extensions/string_extensions.dart';
import 'package:multiroom/app/core/widgets/app_button.dart';
import 'package:signals/signals_flutter.dart';

class TechAccessBottomSheet extends StatelessWidget {
  const TechAccessBottomSheet({
    super.key,
    required this.errorMessage,
    required this.onChangePassword,
    required this.onTapAccess,
    required this.onTapConfigDevice,
    required this.isPasswordVisible,
    required this.onTogglePasswordVisible,
  });

  final String errorMessage;
  final bool isPasswordVisible;
  final Function(String) onChangePassword;
  final Function() onTapAccess;
  final Function()? onTapConfigDevice;
  final Function() onTogglePasswordVisible;

  @override
  Widget build(BuildContext context) {
    return Watch(
      (_) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                "Acesso técnico",
                style: context.textTheme.headlineSmall,
              ),
            ),
            8.asSpace,
            TextFormField(
              obscureText: isPasswordVisible == false,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
                labelText: 'Senha',
                suffixIcon: AnimatedSwitcher(
                  duration: Durations.short3,
                  child: IconButton(
                    key: ValueKey(isPasswordVisible),
                    icon: Icon(isPasswordVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                    onPressed: onTogglePasswordVisible,
                  ),
                ),
              ),
              onChanged: onChangePassword,
              onFieldSubmitted: (_) => onTapConfigDevice?.call() ?? onTapAccess(),
            ),
            AnimatedSwitcher(
              duration: Durations.short2,
              child: Visibility.maintain(
                key: ValueKey("Message_$errorMessage"),
                visible: errorMessage.isNotNullOrEmpty,
                child: Text(
                  errorMessage,
                  style: context.textTheme.labelSmall,
                ),
              ),
            ),
            12.asSpace,
            AppButton(
              text: "Acessar",
              onPressed: onTapConfigDevice ?? onTapAccess,
            ),
            24.asSpace,
          ],
        ),
      ),
    );
  }
}
