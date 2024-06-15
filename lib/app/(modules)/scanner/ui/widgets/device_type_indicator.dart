import 'package:flutter/material.dart';

import '../../../../core/extensions/build_context_extensions.dart';

class DeviceTypeIndicator extends StatelessWidget {
  const DeviceTypeIndicator({
    super.key,
    required this.label,
    required this.active,
  });

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: active ? context.colorScheme.inversePrimary : context.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.colorScheme.primary,
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: Center(
        child: Text(
          label,
          style: context.textTheme.bodyLarge,
        ),
      ),
    );
  }
}
