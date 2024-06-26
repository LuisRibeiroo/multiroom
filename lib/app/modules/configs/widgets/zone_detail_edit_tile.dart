import 'package:flutter/material.dart';

import '../../../core/extensions/build_context_extensions.dart';
import '../../../core/extensions/number_extensions.dart';
import '../../../core/models/zone_model.dart';
import '../../../core/models/zone_wrapper_model.dart';

class ZoneDetailEditTile extends StatelessWidget {
  const ZoneDetailEditTile({
    super.key,
    required this.wrapper,
    required this.zone,
    required this.isEditing,
    required this.onChangeZoneName,
    required this.toggleEditing,
    required this.onTapEditMaxVolume,
    required this.maxVolume,
    this.label = "",
  });

  final String label;
  final ZoneWrapperModel wrapper;
  final ZoneModel zone;
  final bool isEditing;
  final Function(ZoneModel, String) onChangeZoneName;
  final Function(ZoneWrapperModel, ZoneModel) toggleEditing;
  final Function() onTapEditMaxVolume;
  final int maxVolume;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Column(
            children: [
              const Icon(Icons.volume_up_rounded),
              Text("$maxVolume"),
            ],
          ),
          onPressed: onTapEditMaxVolume,
        ),
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
