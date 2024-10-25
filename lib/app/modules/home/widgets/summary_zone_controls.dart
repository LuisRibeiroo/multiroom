import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/extensions/build_context_extensions.dart';
import '../../../core/extensions/number_extensions.dart';
import '../../../core/models/zone_model.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_switch.dart';
import 'slider_icons.dart';

class SummaryZoneControls extends StatelessWidget {
  const SummaryZoneControls({
    super.key,
    required this.isDeviceActive,
    required this.zone,
    required this.onChangeActive,
    required this.onChangeChannel,
    required this.onChangeVolume,
    required this.onTapCard,
  });

  final bool isDeviceActive;
  final ZoneModel zone;
  final Function(bool) onChangeActive;
  final Function() onChangeChannel;
  final Function(int) onChangeVolume;
  final Function(ZoneModel zone) onTapCard;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTapCard(zone),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.settings),
                6.asSpace,
                Expanded(
                  child: Text(
                    "${zone.name}${kDebugMode ? " (${zone.deviceSerial})" : ""}",
                    textAlign: TextAlign.left,
                    style: context.textTheme.bodyLarge,
                  ),
                ),
                AppSwitch(
                  value: zone.active,
                  onChangeActive: onChangeActive,
                ),
              ],
            ),
            1.asSpace,
            SizedBox(
              width: context.sizeOf.width / 2,
              child: AnimatedSwitcher(
                duration: Durations.short4,
                child: AppButton(
                  key: ValueKey("${zone.name}_${zone.channel.name}"),
                  type: ButtonType.secondary,
                  leading: const Icon(Icons.music_note),
                  text: zone.channel.name,
                  onPressed: onChangeChannel,
                ),
              ),
            ),
            // 1.asSpace,
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
