import 'package:flutter/material.dart';

import '../../../../core/enums/device_type.dart';
import '../../../../core/extensions/build_context_extensions.dart';

class DeviceMasterIndicator extends StatelessWidget {
  const DeviceMasterIndicator({
    super.key,
    required this.label,
    required this.type,
  });

  final String label;
  final DeviceType type;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Durations.short3,
      child: Container(
        key: ValueKey("$label$type"),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: type != DeviceType.master ? context.colorScheme.primaryContainer : Colors.transparent,
          border: Border.all(
            color: type != DeviceType.master ? Colors.transparent : context.colorScheme.primaryContainer,
          ),
        ),
        child: Text(
          label,
          style: context.textTheme.bodyLarge!.copyWith(
            color: type != DeviceType.master ? context.colorScheme.onPrimaryContainer : context.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
