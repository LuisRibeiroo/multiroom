import 'package:flutter/material.dart';
import 'package:multiroom/app/(modules)/scanner/ui/widgets/device_master_indicator.dart';
import 'package:multiroom/app/core/extensions/build_context_extensions.dart';
import 'package:multiroom/app/core/extensions/number_extensions.dart';
import 'package:multiroom/app/core/models/device_model.dart';

class DeviceListTile extends StatelessWidget {
  const DeviceListTile({
    super.key,
    required this.device,
    required this.onChangeActive,
    required this.onChangeType,
  });

  final DeviceModel device;
  final Function(DeviceModel, bool) onChangeActive;
  final Function(DeviceModel, String) onChangeType;

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      child: Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: Row(
          children: [
            Checkbox.adaptive(
              value: device.active,
              onChanged: (value) => onChangeActive(device, value!),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.ip,
                    style: context.textTheme.titleMedium,
                  ),
                  Text(
                    "Ver ${device.version}",
                    style: context.textTheme.labelMedium,
                  ),
                ],
              ),
            ),
            12.asSpace,
            Column(
              children: [
                RadioMenuButton(
                  value: "master",
                  groupValue: device.type.name,
                  onChanged: (value) => onChangeType(device, value!),
                  child: const Text("Master"),
                ),
                RadioMenuButton(
                  value: "slave1",
                  groupValue: device.type.name,
                  onChanged: (value) => onChangeType(device, value!),
                  child: const Text("Slave1"),
                ),
                RadioMenuButton(
                  value: "slave2",
                  groupValue: device.type.name,
                  onChanged: (value) => onChangeType(device, value!),
                  child: const Text("Slave2"),
                ),
              ],
            ),
            12.asSpace,
            Column(
              children: [
                DeviceMasterIndicator(
                  label: "M1",
                  type: device.type,
                ),
                DeviceMasterIndicator(
                  label: "M2",
                  type: device.type,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
