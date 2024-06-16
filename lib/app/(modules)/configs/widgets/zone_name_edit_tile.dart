import 'package:flutter/material.dart';

import '../../../core/extensions/build_context_extensions.dart';
import '../../../core/extensions/number_extensions.dart';
import '../../../core/models/zone_model.dart';
import '../../../core/models/zone_wrapper_model.dart';

class ZoneNameEditTile extends StatelessWidget {
  const ZoneNameEditTile({
    super.key,
    required this.wrapper,
    required this.zone,
    required this.isEditing,
    required this.onChangeZoneName,
    required this.toggleEditing,
    this.label = "",
  });

  final String label;
  final ZoneWrapperModel wrapper;
  final ZoneModel zone;
  final bool isEditing;
  final Function(ZoneModel, String) onChangeZoneName;
  final Function(ZoneWrapperModel, ZoneModel) toggleEditing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            enabled: isEditing,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: label,
            ),
            initialValue: zone.name,
            onChanged: (value) => onChangeZoneName(zone, value),
            style: context.textTheme.titleSmall,
          ),
        ),
        12.asSpace,
        IconButton(
          onPressed: () => toggleEditing(wrapper, zone),
          icon: AnimatedSwitcher(
            duration: Durations.short3,
            child: Icon(
              key: ValueKey(isEditing),
              isEditing ? Icons.check_rounded : Icons.edit_rounded,
            ),
          ),
        ),
      ],
    );
  }
}
