import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../core/enums/device_type.dart';
import '../../../core/extensions/build_context_extensions.dart';
import '../../../core/extensions/number_extensions.dart';
import '../../../core/models/device_model.dart';
import '../../../core/widgets/device_state_indicator.dart';
import '../../widgets/icon_text_tile.dart';

class DeviceListTile extends StatelessWidget {
  const DeviceListTile({
    super.key,
    required this.device,
    required this.onTapConfigDevice,
    required this.showAvailability,
  });

  final DeviceModel device;
  final Function(DeviceModel) onTapConfigDevice;
  final bool showAvailability;

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      child: InkWell(
        onTap: () => onTapConfigDevice(device),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconTextTile(
                      icon: Icons.surround_sound_rounded,
                      text: device.name,
                      style: context.textTheme.titleLarge,
                    ),
                    12.asSpace,
                    IconTextTile(
                      icon: MdiIcons.ip,
                      text: device.ip,
                      style: context.textTheme.bodyLarge,
                    ),
                    IconTextTile(
                      icon: Icons.document_scanner_rounded,
                      text: device.serialNumber,
                    ),
                    IconTextTile(
                      icon: Icons.info_rounded,
                      text: "Ver ${device.version}",
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Visibility(
                      visible: showAvailability,
                      child: DeviceStateIndicator(value: device.active),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: device.type == DeviceType.master
                            ? context.colorScheme.inversePrimary
                            : context.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: context.colorScheme.primary,
                        ),
                      ),
                      child: Text(
                        device.type.name[0].toUpperCase(),
                        style: context.textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
