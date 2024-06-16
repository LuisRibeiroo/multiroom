import 'package:flutter/material.dart';

import '../../../core/enums/device_type.dart';
import '../../../core/extensions/build_context_extensions.dart';
import '../../../core/extensions/number_extensions.dart';
import '../../../core/extensions/string_extensions.dart';
import '../../../core/models/device_model.dart';
import 'device_type_indicator.dart';

class DeviceListTile extends StatelessWidget {
  const DeviceListTile({
    super.key,
    required this.device,
    required this.onChangeActive,
    required this.onTapConfigDevice,
  });

  final DeviceModel device;
  final Function(DeviceModel, bool) onChangeActive;
  final Function(DeviceModel) onTapConfigDevice;

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      child: InkWell(
        onTap: () => onTapConfigDevice(device),
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
                      device.serialNumber,
                      style: context.textTheme.labelMedium,
                    ),
                    Text(
                      "V ${device.version}",
                      style: context.textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
              12.asSpace,
              Flexible(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DeviceTypeIndicator(
                            label: device.type.name.capitalize,
                            active: device.type == DeviceType.slave,
                          ),
                        ),
                      ],
                    ),
                    Visibility.maintain(
                      visible: device.type != DeviceType.master,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Flexible(
                            child: DeviceTypeIndicator(
                              label: "S1",
                              active: false,
                            ),
                          ),
                          8.asSpace,
                          const Flexible(
                            child: DeviceTypeIndicator(
                              label: "S2",
                              active: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              12.asSpace,
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Icon(
                  Icons.tune_rounded,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
