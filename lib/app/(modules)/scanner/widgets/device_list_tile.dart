import 'package:flutter/material.dart';
import 'package:multiroom/app/core/enums/device_type.dart';

import '../../../core/extensions/build_context_extensions.dart';
import '../../../core/extensions/number_extensions.dart';
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
                      device.name,
                      style: context.textTheme.titleLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    8.asSpace,
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                device.ip,
                                style: context.textTheme.bodyLarge,
                              ),
                              Text(
                                device.serialNumber,
                                style: context.textTheme.bodySmall,
                              ),
                              Text(
                                "V ${device.version}",
                                style: context.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        DeviceTypeIndicator(
                          label: device.type.name[0].toUpperCase(),
                          active: device.type == DeviceType.master,
                        ),
                      ],
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
