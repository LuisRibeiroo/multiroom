import 'package:flutter/material.dart';

import '../../core/extensions/build_context_extensions.dart';
import '../../core/extensions/number_extensions.dart';
import '../../core/models/channel_model.dart';
import '../../core/models/zone_model.dart';

class DeviceInfoHeader extends StatefulWidget {
  const DeviceInfoHeader({
    super.key,
    required this.deviceName,
    required this.zones,
    required this.currentZone,
    required this.currentChannel,
    required this.onChangeZone,
    required this.onChangeChannel,
  });

  final String deviceName;
  final List<ZoneModel> zones;
  final ZoneModel currentZone;
  final ChannelModel currentChannel;
  final Function() onChangeChannel;
  final Function() onChangeZone;

  @override
  State<DeviceInfoHeader> createState() => _DeviceInfoHeaderState();
}

class _DeviceInfoHeaderState extends State<DeviceInfoHeader> {
  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    widget.deviceName,
                    style: context.textTheme.headlineSmall,
                  ),
                ),
                12.asSpace,
                Flexible(
                  flex: 2,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: Durations.short4,
                              child: OutlinedButton.icon(
                                key: ValueKey(widget.currentZone.name),
                                icon: const Icon(Icons.surround_sound_rounded),
                                label: Text(widget.currentZone.name),
                                onPressed: widget.onChangeZone,
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
                                key: ValueKey(widget.currentChannel.name),
                                icon: const Icon(Icons.input_rounded),
                                label: Text(widget.currentChannel.name),
                                onPressed: widget.onChangeChannel,
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
          ],
        ),
      ),
    );
  }
}
