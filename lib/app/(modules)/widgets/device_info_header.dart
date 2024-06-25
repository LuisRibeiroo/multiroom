import 'package:flutter/material.dart';

import '../../core/extensions/number_extensions.dart';
import '../../core/models/channel_model.dart';
import '../../core/models/zone_model.dart';
import '../../core/widgets/app_button.dart';

class DeviceInfoHeader extends StatelessWidget {
  const DeviceInfoHeader({
    super.key,
    required this.deviceName,
    required this.currentZone,
    required this.currentChannel,
    required this.onChangeChannel,
    required this.onChangeDevice,
  });

  final String deviceName;
  final ZoneModel currentZone;
  final ChannelModel currentChannel;
  final Function() onChangeChannel;
  final Function() onChangeDevice;

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    leading: const Icon(Icons.surround_sound_rounded),
                    text: "$deviceName - ${currentZone.name}",
                    onPressed: onChangeDevice,
                  ),
                ),
                12.asSpace,
                Switch(value: false, onChanged: (v) {}),
              ],
            ),
            18.asSpace,
            AnimatedSwitcher(
              duration: Durations.short4,
              child: AppButton(
                type: ButtonType.secondary,
                key: ValueKey(currentChannel.name),
                leading: const Icon(Icons.input_rounded),
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
