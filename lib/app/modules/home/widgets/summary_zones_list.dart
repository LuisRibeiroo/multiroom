import 'package:flutter/material.dart';

import '../../../core/extensions/build_context_extensions.dart';
import '../../../core/extensions/number_extensions.dart';
import '../../../core/models/zone_model.dart';
import '../../widgets/icon_text_tile.dart';
import 'summary_zone_controls.dart';

class SummaryZonesList extends StatelessWidget {
  const SummaryZonesList({
    super.key,
    required this.zones,
    required this.onChangeActive,
    required this.onChangeChannel,
    required this.onChangeVolume,
    required this.onTapZone,
  });

  final List<ZoneModel> zones;
  final Function(bool, {ZoneModel? zone}) onChangeActive;
  final Function({ZoneModel? zone}) onChangeChannel;
  final Function(int, {ZoneModel? zone}) onChangeVolume;
  final Function(ZoneModel zone) onTapZone;

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: IconTextTile(
                icon: Icons.home_filled,
                text: "Zonas",
                style: context.textTheme.titleLarge,
              ),
            ),
            12.asSpace,
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: zones.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final zone = zones[index];

                  return SummaryZoneControls(
                    zone: zone,
                    onTapCard: onTapZone,
                    onChangeActive: (value) => onChangeActive(value, zone: zone),
                    onChangeChannel: () => onChangeChannel(zone: zone),
                    onChangeVolume: (value) => onChangeVolume(value, zone: zone),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
