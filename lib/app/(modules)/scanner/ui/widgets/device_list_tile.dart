import 'package:flutter/material.dart';
import 'package:multiroom/app/core/enums/device_type.dart';
import 'package:routefly/routefly.dart';

import '../../../../../routes.g.dart';
import '../../../../core/extensions/build_context_extensions.dart';
import '../../../../core/extensions/number_extensions.dart';
import '../../../../core/extensions/string_extensions.dart';
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
                    "Versão: ${device.version}",
                    style: context.textTheme.labelMedium,
                  ),
                  Text(
                    "Serial: ${device.serialNumber}",
                    style: context.textTheme.labelMedium,
                  ),
                ],
              ),
            ),
            12.asSpace,
            // FIXME: Descobrir como definir qual item está ativo
            Flexible(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: context.colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: context.colorScheme.primary,
                            ),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Center(child: Text(device.type.name.capitalize)),
                        ),
                      )
                    ],
                  ),
                  Visibility.maintain(
                    visible: device.type != DeviceType.master,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DeviceMasterIndicator(
                          label: "M1",
                          type: device.type,
                        ),
                        8.asSpace,
                        DeviceMasterIndicator(
                          label: "M2",
                          type: device.type,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            12.asSpace,
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => Routefly.pushNavigate(
                    routePaths.devices.ui.pages.deviceConfiguration,
                    arguments: device,
                  ),
                  icon: const Icon(Icons.tune_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
