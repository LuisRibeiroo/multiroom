import 'package:flutter/material.dart';
import 'package:routefly/routefly.dart';

import '../../../../../routes.g.dart';
import '../../../../core/extensions/build_context_extensions.dart';
import '../../../../core/extensions/number_extensions.dart';
import '../../../../core/models/device_model.dart';
import 'device_master_indicator.dart';

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
        padding: const EdgeInsets.only(top: 12.0, bottom: 12.0, right: 12.0),
        child: Row(
          children: [
            Checkbox(
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
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton.outlined(
                  onPressed: () => Routefly.pushNavigate(routePaths.devices.ui.pages.deviceConfiguration),
                  icon: const Icon(Icons.tune_rounded),
                ),
                Row(
                  children: [
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
                        8.asSpace,
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
