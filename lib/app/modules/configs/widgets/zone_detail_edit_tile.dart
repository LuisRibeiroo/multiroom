import 'package:flutter/material.dart';

import '../../../core/models/zone_model.dart';
import '../../../core/models/zone_wrapper_model.dart';
import '../../shared/widgets/text_edit_tile.dart';

class ZoneDetailEditTile extends StatelessWidget {
  const ZoneDetailEditTile({
    super.key,
    required this.wrapper,
    required this.zone,
    required this.isEditing,
    required this.onChangeZoneName,
    required this.onChangeZoneVisible,
    required this.toggleEditing,
    required this.hideEditButton,
    this.label = "",
  });

  final String label;
  final ZoneWrapperModel wrapper;
  final ZoneModel zone;
  final bool isEditing;
  final Function(ZoneModel, String) onChangeZoneName;
  final Function(ZoneWrapperModel, ZoneModel, bool) onChangeZoneVisible;
  final Function(ZoneWrapperModel, ZoneModel) toggleEditing;
  final bool hideEditButton;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextEditTile(
            itemId: label,
            initialValue: zone.name,
            isEditing: isEditing,
            onChangeValue: (_, value) => onChangeZoneName(zone, value),
            toggleEditing: (_) => toggleEditing(wrapper, zone),
            toggleZoneVisible: () => onChangeZoneVisible(wrapper, zone, !zone.visible),
            hideEditButton: hideEditButton,
            hideZone: !zone.visible,
          ),
        ),
      ],
    );
  }
}
