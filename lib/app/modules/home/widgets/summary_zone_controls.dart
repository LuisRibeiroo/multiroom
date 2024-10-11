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
    return Card.outlined(
      margin: const EdgeInsets.all(1.0),
      shape: const RoundedRectangleBorder(side: BorderSide.none
          // side: const BorderSide(color: Colors.white70, width: 1),
          // borderRadius: BorderRadius.circular(1),
          ),
      child: InkWell(
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
              1.asSpace,
              SizedBox(
                width: context.sizeOf.width / 2,
                child: AnimatedSwitcher(
                  duration: Durations.short4,
                  // child: ElevatedButton.icon(
                  //     style: ButtonStyle(
                  //         minimumSize: WidgetStateProperty.all(Size(context.sizeOf.width / 2, 45)),
                  //         foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                  //         backgroundColor: WidgetStateProperty.all<Color>(Colors.white12),
                  //         shape: WidgetStateProperty.all<RoundedRectangleBorder>(const RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.all(Radius.circular(10)),
                  //             side: BorderSide(color: Colors.white12)))),
                  //     onPressed: onChangeChannel,
                  //     icon: const Icon(Icons.music_note),
                  //     label: Text(zone.channel.name, style: const TextStyle(fontSize: 14)))
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
      ),
    );
  }
}
