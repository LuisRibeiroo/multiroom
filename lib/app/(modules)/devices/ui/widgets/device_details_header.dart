import 'package:flutter/material.dart';
import 'package:multiroom/app/core/extensions/number_extensions.dart';

import '../../../../core/extensions/build_context_extensions.dart';
import '../../../../core/models/input_model.dart';
import '../../../../core/models/zone_model.dart';
import '../../interactor/models/device_model.dart';

class DeviceDetailsHeader extends StatelessWidget {
  const DeviceDetailsHeader({
    super.key,
    required this.device,
    required this.currentZone,
    required this.currentInput,
  });

  final DeviceModel device;
  final ZoneModel currentZone;
  final InputModel currentInput;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Durations.medium1,
      child: device.isEmpty
          ? const SizedBox.shrink()
          : Card.outlined(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            device.name,
                            style: context.textTheme.headlineSmall,
                          ),
                        ),
                        12.asSpace,
                        Expanded(
                          child: Text(
                            currentZone.name,
                            style: context.textTheme.titleMedium,
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      device.name,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
