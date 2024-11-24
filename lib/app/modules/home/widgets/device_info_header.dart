import 'package:flutter/material.dart';

import '../../../core/extensions/number_extensions.dart';
import '../../../core/models/channel_model.dart';
import '../../../core/models/project_model.dart';
import '../../../core/models/zone_model.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_switch.dart';

class DeviceInfoHeader extends StatelessWidget {
  const DeviceInfoHeader({
    super.key,
    required this.project,
    required this.deviceName,
    required this.currentZone,
    required this.currentChannel,
    required this.onChangeChannel,
    required this.onChangeDevice,
    required this.onChangeActive,
    required this.onChangeProject,
  });

  final ProjectModel project;
  final String deviceName;
  final ZoneModel currentZone;
  final ChannelModel currentChannel;
  final Function() onChangeChannel;
  final Function() onChangeDevice;
  final Function() onChangeProject;
  final Function(bool, ZoneModel) onChangeActive;

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 12, bottom: 24, top: 12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: AppButton(
                    leading: const Icon(Icons.surround_sound_rounded),
                    text: "$deviceName - ${currentZone.name}",
                    onPressed: onChangeDevice,
                  ),
                ),
                12.asSpace,
                AppSwitch(
                  value: currentZone.active,
                  onChangeActive: (value) => onChangeActive(value, currentZone),
                ),
              ],
            ),
            18.asSpace,
            AnimatedSwitcher(
              duration: Durations.short4,
              child: AppButton(
                type: ButtonType.secondary,
                key: ValueKey(currentChannel.name),
                leading: const Icon(Icons.music_note),
                text: currentChannel.name,
                onPressed: onChangeChannel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
