import 'package:flutter/material.dart';

import '../../../core/extensions/build_context_extensions.dart';
import '../../../core/extensions/number_extensions.dart';
import '../../../core/models/zone_model.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_switch.dart';
import '../../../core/widgets/device_state_indicator.dart';
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
    return Card.outlined(
      child: InkWell(
        onTap: () => onTapCard(zone),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Column(
            children: [
              DeviceStateIndicator(value: isDeviceActive),
              18.asSpace,
              Row(
                children: [
                  const Icon(Icons.home_filled),
                  12.asSpace,
                  Expanded(
                    child: Text(
                      zone.name,
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
              18.asSpace,
              SizedBox(
                width: context.sizeOf.width / 2,
                child: AnimatedSwitcher(
                  duration: Durations.short4,
                  child: AppButton(
                    key: ValueKey("${zone.name}_${zone.channel.name}"),
                    type: ButtonType.secondary,
                    leading: const Icon(Icons.input_rounded),
                    text: zone.channel.name,
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
      ),
    );
  }
}
