import 'package:flutter/material.dart';

import '../../core/extensions/build_context_extensions.dart';
import '../../core/extensions/number_extensions.dart';
import '../../core/models/channel_model.dart';
import '../../core/models/zone_group_model.dart';
import '../../core/models/zone_model.dart';

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
              child: OutlinedButton.icon(
                icon: const Icon(Icons.surround_sound_rounded),
                label: AnimatedSwitcher(
                  duration: Durations.short4,
                  child: Text(
                    deviceName,
                    key: ValueKey(deviceName),
                    style: context.textTheme.titleLarge!.copyWith(
                      color: context.theme.buttonTheme.colorScheme!.primary,
                    ),
                  ),
                ),
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
                            replacement: OutlinedButton.icon(
                              key: ValueKey(currentGroup.name),
                              icon: const Icon(Icons.group_work_rounded),
                              label: Text(currentGroup.name),
                              onPressed: onChangeZoneGroup,
                            ),
                            child: OutlinedButton.icon(
                              key: ValueKey(currentZone.name),
                              icon: const Icon(Icons.home_filled),
                              label: Text(currentZone.name),
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
                          child: OutlinedButton.icon(
                            key: ValueKey(currentChannel.name),
                            icon: const Icon(Icons.input_rounded),
                            label: Text(currentChannel.name),
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
