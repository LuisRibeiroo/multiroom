import 'package:flutter/material.dart';

import '../../../core/enums/device_type.dart';
import '../../../core/extensions/build_context_extensions.dart';
import '../../../core/extensions/number_extensions.dart';
import '../../../core/extensions/string_extensions.dart';
import '../../../core/models/device_model.dart';
import '../../scanner/widgets/device_type_indicator.dart';
import 'delete_device_confirm_bottom_sheet.dart';

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
      child: DeleteDeviceConfirmBottomSheet(
        deviceName: device.name,
        onConfirm: onDeleteDevice,
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.ip,
                      style: context.textTheme.titleMedium,
                    ),
                    4.asSpace,
                    Text(
                      device.serialNumber,
                    ),
                    Text(
                      "Ver ${device.version}",
                    ),
                  ],
                ),
                12.asSpace,
                const Spacer(),
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
