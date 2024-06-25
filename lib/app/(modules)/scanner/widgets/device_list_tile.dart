import 'package:flutter/material.dart';

import '../../../core/enums/device_type.dart';
import '../../../core/extensions/build_context_extensions.dart';
import '../../../core/extensions/number_extensions.dart';
import '../../../core/models/device_model.dart';

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
              12.asSpace,
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
                                "Ver ${device.version}",
                                style: context.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
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
