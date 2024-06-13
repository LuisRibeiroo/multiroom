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
    return Chip(
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.all(2),
      backgroundColor: type != DeviceType.master ? context.colorScheme.inversePrimary : Colors.transparent,
      label: Text(label, style: context.textTheme.bodyLarge),
    );
  }
}
