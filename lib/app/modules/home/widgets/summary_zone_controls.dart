import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';

import '../../../core/extensions/build_context_extensions.dart';
import '../../../core/extensions/number_extensions.dart';
import '../../../core/models/zone_model.dart';
import '../../../core/widgets/app_button.dart';
import 'slider_icons.dart';

class SummaryZoneControls extends StatelessWidget {
  const SummaryZoneControls({
    super.key,
    required this.zone,
    required this.onChangeActive,
    required this.onChangeChannel,
    required this.onChangeVolume,
  });

  final ZoneModel zone;
  final Function(bool) onChangeActive;
  final Function() onChangeChannel;
  final Function(int) onChangeVolume;

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.settings_rounded),
                24.asSpace,
                Expanded(
                  child: Text(
                    zone.name,
                    textAlign: TextAlign.left,
                    style: context.textTheme.bodyLarge,
                  ),
                ),
                AnimatedToggleSwitch.dual(
                  current: zone.active,
                  first: false,
                  second: true,
                  onChanged: onChangeActive,
                  height: 40,
                  indicatorSize: const Size.square(38),
                  textBuilder: (value) => Text(
                    value ? "ON" : "OFF",
                    style: context.textTheme.titleSmall,
                  ),
                  iconBuilder: (value) => Icon(
                    value ? Icons.power_rounded : Icons.power_off_rounded,
                    color: context.colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
            18.asSpace,
            AnimatedSwitcher(
              duration: Durations.short4,
              child: SizedBox(
                width: context.sizeOf.width / 2,
                child: AppButton(
                  type: ButtonType.secondary,
                  key: const ValueKey("Channel 1"),
                  leading: const Icon(Icons.input_rounded),
                  text: "Channel 1",
                  onPressed: onChangeChannel,
                ),
              ),
            ),
            8.asSpace,
            SliderIcons(
              value: zone.volume,
              onChanged: onChangeVolume,
            ),
          ],
        ),
      ),
    );
  }
}
