import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:routefly/routefly.dart';

import '../../../core/enums/device_type.dart';
import '../../../core/extensions/build_context_extensions.dart';
import '../../../core/extensions/number_extensions.dart';
import '../../../core/extensions/string_extensions.dart';
import '../../../core/models/device_model.dart';
import '../../scanner/widgets/device_type_indicator.dart';
import '../../widgets/delete_confirmation_bottom_sheet.dart';
import '../../widgets/icon_text_tile.dart';

class DeviceConfigHeader extends StatelessWidget {
  const DeviceConfigHeader({
    super.key,
    required this.deviceName,
    required this.device,
    required this.isEditingDevice,
    required this.toggleEditingDevice,
    required this.onDeleteDevice,
    required this.onChangeDeviceName,
  });

  final String deviceName;
  final DeviceModel device;
  final bool isEditingDevice;
  final Function() toggleEditingDevice;
  final Function() onDeleteDevice;
  final Function(String) onChangeDeviceName;

  void _showDeviceDeletionBottomSheet(BuildContext context) {
    context.showCustomModalBottomSheet(
      isScrollControlled: false,
      child: DeleteConfirmationBottomSheet(
        deviceName: device.name,
        onConfirm: () {
          onDeleteDevice();
          Routefly.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                DeviceTypeIndicator(
                  active: device.type == DeviceType.master,
                  label: device.type.name.capitalize,
                ),
                12.asSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconTextTile(
                        icon: Icons.group_work_rounded,
                        text: device.projectName,
                        style: context.textTheme.titleMedium,
                      ),
                      12.asSpace,
                      IconTextTile(
                        icon: MdiIcons.ip,
                        text: device.ip,
                        style: context.textTheme.titleMedium,
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
                12.asSpace,
                IconButton.outlined(
                  onPressed: () => _showDeviceDeletionBottomSheet(context),
                  icon: const Icon(Icons.delete_rounded),
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    enabled: isEditingDevice,
                    onChanged: onChangeDeviceName,
                    initialValue: deviceName,
                    style: context.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.surround_sound_rounded),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                12.asSpace,
                IconButton(
                  onPressed: toggleEditingDevice,
                  icon: AnimatedSwitcher(
                    duration: Durations.short3,
                    child: Icon(
                      key: ValueKey(isEditingDevice),
                      isEditingDevice ? Icons.check_rounded : Icons.edit_rounded,
                    ),
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
