import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';

import '../extensions/build_context_extensions.dart';

class DeviceStateIndicator extends StatelessWidget {
  const DeviceStateIndicator({
    super.key,
    required this.value,
  });

  final bool value;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: AnimatedToggleSwitch.dual(
        current: value,
        first: false,
        second: true,
        height: 32,
        indicatorSize: const Size.square(28),
        style: ToggleStyle(
          indicatorColor: context.colorScheme.inversePrimary,
          borderColor: context.colorScheme.inversePrimary,
        ),
        iconBuilder: (value) => Icon(
          value ? Icons.wifi_rounded : Icons.wifi_off_rounded,
          color: value ? context.colorScheme.primary : context.theme.disabledColor,
          size: 20,
        ),
        fittingMode: FittingMode.preventHorizontalOverlapping,
        textBuilder: (value) => Text(
          value ? "ONLINE" : "OFFLINE",
          style: context.textTheme.labelSmall,
        ),
      ),
    );
  }
}
