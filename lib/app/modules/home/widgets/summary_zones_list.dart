import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../../core/extensions/build_context_extensions.dart';
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
  final Function(bool, ZoneModel zone) onChangeActive;
  final Function(ZoneModel zone) onChangeChannel;
  final Function(int, {ZoneModel zone}) onChangeVolume;
  final Function(ZoneModel zone) onTapZone;

  @override
  State<SummaryZonesList> createState() => _SummaryZonesListState();
}

class _SummaryZonesListState extends State<SummaryZonesList> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Durations.short3,
      child: widget.zones.isEmpty
          ? Center(
              child: Column(
                children: [
                  Icon(Icons.search_off_rounded, size: 50, color: context.colorScheme.onSurface),
                  Text('Nada encontrado', style: context.textTheme.labelLarge),
                ],
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              itemCount: widget.zones.length,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (context, index) =>
                  widget.zones[index].visible ? const Divider(color: Colors.white30) : const SizedBox(height: 0),
              itemBuilder: (context, index) {
                final zone = widget.zones[index];
                final device = widget.devices.firstWhereOrNull((element) => element.serialNumber == zone.deviceSerial);

                return Visibility(
                  visible: zone.visible,
                  child: SummaryZoneControls(
                    isDeviceActive: device?.active ?? false,
                    zone: zone,
                    onTapCard: widget.onTapZone,
                    onChangeActive: (value) => widget.onChangeActive(value, zone),
                    onChangeChannel: () => widget.onChangeChannel(zone),
                    onChangeVolume: (value) => widget.onChangeVolume(value, zone: zone),
                  ),
                );
              },
            ),
    );
  }
}
