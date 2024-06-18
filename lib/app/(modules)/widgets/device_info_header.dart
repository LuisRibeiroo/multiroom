import 'package:flutter/material.dart';

import '../../core/extensions/number_extensions.dart';
import '../../core/models/channel_model.dart';
import '../../core/models/zone_group_model.dart';
import '../../core/models/zone_model.dart';
import '../../core/widgets/app_button.dart';

class DeviceInfoHeader extends StatelessWidget {
  const DeviceInfoHeader({
    super.key,
    required this.deviceName,
    required this.currentZone,
    required this.currentGroup,
    required this.currentChannel,
    required this.onChangeChannel,
    required this.onChangeZoneGroup,
    required this.onChangeDevice,
  });

  final String deviceName;
  final ZoneModel currentZone;
  final ZoneGroupModel currentGroup;
  final ChannelModel currentChannel;
  final Function() onChangeChannel;
  final Function() onChangeZoneGroup;
  final Function() onChangeDevice;

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Expanded(
              flex: 6,
              child: AppButton(
                leading: const Icon(Icons.surround_sound_rounded),
                text: deviceName,
                onPressed: onChangeDevice,
              ),
            ),
            12.asSpace,
            Flexible(
              flex: 5,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: Durations.short4,
                          child: Visibility(
                            visible: currentGroup.isEmpty,
                            replacement: AppButton(
                              type: ButtonType.secondary,
                              key: ValueKey(currentGroup.name),
                              leading: const Icon(Icons.group_work_rounded),
                              text: currentGroup.name,
                              onPressed: onChangeZoneGroup,
                            ),
                            child: AppButton(
                              type: ButtonType.secondary,
                              key: ValueKey(currentZone.name),
                              leading: const Icon(Icons.home_filled),
                              text: currentZone.name,
                              onPressed: onChangeZoneGroup,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  8.asSpace,
                  Row(
                    children: [
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: Durations.short4,
                          child: AppButton(
                            type: ButtonType.secondary,
                            key: ValueKey(currentChannel.name),
                            leading: const Icon(Icons.input_rounded),
                            text: currentChannel.name,
                            onPressed: onChangeChannel,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
