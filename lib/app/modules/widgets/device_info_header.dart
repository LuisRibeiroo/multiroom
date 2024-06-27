import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';

import '../../core/extensions/build_context_extensions.dart';
import '../../core/extensions/number_extensions.dart';
import '../../core/models/channel_model.dart';
import '../../core/models/project_model.dart';
import '../../core/models/zone_model.dart';
import '../../core/widgets/app_button.dart';

class DeviceInfoHeader extends StatelessWidget {
  const DeviceInfoHeader({
    super.key,
    required this.showProjectsButton,
    required this.project,
    required this.deviceName,
    required this.currentZone,
    required this.currentChannel,
    required this.onChangeChannel,
    required this.onChangeDevice,
    required this.onChangeActive,
    required this.onChangeProject,
  });

  final bool showProjectsButton;
  final ProjectModel project;
  final String deviceName;
  final ZoneModel currentZone;
  final ChannelModel currentChannel;
  final Function() onChangeChannel;
  final Function() onChangeDevice;
  final Function() onChangeProject;
  final Function(bool) onChangeActive;

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
        child: Column(
          children: [
            AnimatedSize(
              duration: Durations.short4,
              child: Visibility(
                visible: showProjectsButton,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: AppButton(
                    type: ButtonType.primary,
                    text: project.name,
                    leading: const Icon(Icons.group_work_rounded),
                    onPressed: onChangeProject,
                  ),
                ),
              ),
            ),
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
                AnimatedToggleSwitch.dual(
                  current: currentZone.active,
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
