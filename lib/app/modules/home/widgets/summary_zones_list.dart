import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../../core/models/device_model.dart';
import '../../../core/models/zone_model.dart';
import 'summary_zone_controls.dart';

class SummaryZonesList extends StatefulWidget {
  const SummaryZonesList({
    super.key,
    required this.devices,
    required this.zones,
    required this.onChangeActive,
    required this.onChangeChannel,
    required this.onChangeVolume,
    required this.onTapZone,
  });

  final List<DeviceModel> devices;
  final List<ZoneModel> zones;
  final Function(bool, {ZoneModel? zone}) onChangeActive;
  final Function({ZoneModel? zone}) onChangeChannel;
  final Function(int, {ZoneModel? zone}) onChangeVolume;
  final Function(ZoneModel zone) onTapZone;

  @override
  State<SummaryZonesList> createState() => _SummaryZonesListState();
}

class _SummaryZonesListState extends State<SummaryZonesList> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1.asSpace,
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: widget.zones.length,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) => const Divider(color: Colors.white30),
            itemBuilder: (context, index) {
              final zone = widget.zones[index];

              return SummaryZoneControls(
                isDeviceActive:
                    widget.devices.firstWhereOrNull((element) => element.serialNumber == zone.deviceSerial)?.active ??
                        false,
                zone: zone,
                onTapCard: widget.onTapZone,
                onChangeActive: (value) => widget.onChangeActive(value, zone: zone),
                onChangeChannel: () => widget.onChangeChannel(zone: zone),
                onChangeVolume: (value) => widget.onChangeVolume(value, zone: zone),
              );
            },
          ),
        ),
      ],
    );
  }
}
