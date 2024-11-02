import 'package:flutter/material.dart';

import '../../../core/extensions/number_extensions.dart';
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
        AnimatedSize(
          duration: Durations.short3,
          child: AnimatedSwitcher(
            duration: Durations.short3,
            child: IconButton(
              key: ValueKey("${zone.id}_${zone.visible}"),
              onPressed: () => onChangeZoneVisible(wrapper, zone, !zone.visible),
              icon: Icon(
                zone.visible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
              ),
            ),
          ),
        ),
        6.asSpace,
        Expanded(
          child: TextEditTile(
            itemId: label,
            initialValue: zone.name,
            isEditing: isEditing,
            onChangeValue: (_, value) => onChangeZoneName(zone, value),
            toggleEditing: (_) => toggleEditing(wrapper, zone),
            hideEditButton: hideEditButton,
          ),
        ),
      ],
    );
  }
}
