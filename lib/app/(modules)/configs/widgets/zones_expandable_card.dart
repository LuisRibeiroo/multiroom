import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../../../core/extensions/build_context_extensions.dart';
import '../../../core/extensions/number_extensions.dart';
import '../../../core/extensions/string_extensions.dart';
import '../../../core/models/zone_model.dart';
import '../../../core/models/zone_wrapper_model.dart';
import 'zone_name_edit_tile.dart';

class ZonesExpandableCard extends StatelessWidget {
  const ZonesExpandableCard({
    super.key,
    required this.zones,
    required this.editingWrapper,
    required this.isEditing,
    required this.onChangeZoneMode,
    required this.onChangeZoneName,
    required this.toggleEditingZone,
    required this.expandableController,
  });

  final ExpandableController expandableController;
  final bool isEditing;
  final List<ZoneWrapperModel> zones;
  final ZoneWrapperModel editingWrapper;
  final Function(ZoneWrapperModel, bool) onChangeZoneMode;
  final Function(ZoneModel, String) onChangeZoneName;
  final Function(ZoneWrapperModel, ZoneModel) toggleEditingZone;

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      clipBehavior: Clip.hardEdge,
      child: ExpandablePanel(
        controller: expandableController,
        theme: ExpandableThemeData(
          iconColor: context.colorScheme.onSurface,
          iconPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18.0),
        ),
        header: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18.0),
          child: Text(
            "Zonas",
            style: context.textTheme.titleMedium,
          ),
        ),
        collapsed: const SizedBox.shrink(),
        expanded: Padding(
          padding: const EdgeInsets.only(bottom: 12.0, left: 12, right: 12),
          child: Column(
            children: [
              const Divider(),
              ...List.generate(
                zones.length,
                (idx) {
                  final wrapper = zones[idx];

                  return Watch(
                    (_) => Column(
                      children: [
                        SwitchListTile(
                          title: Text("Zona ${idx + 1}"),
                          subtitle: Text(wrapper.mode.name.capitalize),
                          value: wrapper.isStereo,
                          secondary: const Icon(Icons.home_filled),
                          onChanged: (value) => onChangeZoneMode(wrapper, value),
                        ),
                        8.asSpace,
                        AnimatedSize(
                          duration: Durations.medium2,
                          child: Column(
                            key: ValueKey(wrapper.isStereo),
                            children: [
                              Visibility(
                                visible: wrapper.isStereo,
                                child: ZoneNameEditTile(
                                  zone: wrapper.stereoZone,
                                  wrapper: wrapper,
                                  isEditing: editingWrapper.id == wrapper.id && isEditing,
                                  onChangeZoneName: onChangeZoneName,
                                  toggleEditing: toggleEditingZone,
                                ),
                              ),
                              Visibility(
                                visible: wrapper.isStereo == false,
                                child: ZoneNameEditTile(
                                  label: wrapper.monoZones.right.id,
                                  zone: wrapper.monoZones.right,
                                  wrapper: wrapper,
                                  isEditing: editingWrapper.id == wrapper.monoZones.right.id && isEditing,
                                  onChangeZoneName: onChangeZoneName,
                                  toggleEditing: toggleEditingZone,
                                ),
                              ),
                              8.asSpace,
                              Visibility(
                                visible: wrapper.isStereo == false,
                                child: ZoneNameEditTile(
                                  label: wrapper.monoZones.left.id,
                                  zone: wrapper.monoZones.left,
                                  wrapper: wrapper,
                                  isEditing: editingWrapper.id == wrapper.monoZones.left.id && isEditing,
                                  onChangeZoneName: onChangeZoneName,
                                  toggleEditing: toggleEditingZone,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
