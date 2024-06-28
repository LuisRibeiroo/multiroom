import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../../../core/extensions/build_context_extensions.dart';
import '../../../core/extensions/number_extensions.dart';
import '../../../core/extensions/string_extensions.dart';
import '../../../core/models/zone_model.dart';
import '../../../core/models/zone_wrapper_model.dart';
import 'zone_detail_edit_tile.dart';

class ZonesExpandableCard extends StatelessWidget {
  const ZonesExpandableCard({
    super.key,
    required this.zones,
    required this.editingWrapper,
    required this.editingZone,
    required this.isEditing,
    required this.onChangeZoneMode,
    required this.onChangeZoneName,
    required this.toggleEditingZone,
    required this.expandableController,
    required this.onEdtiMaxVolume,
  });

  final ExpandableController expandableController;
  final bool isEditing;
  final List<ZoneWrapperModel> zones;
  final ZoneWrapperModel editingWrapper;
  final ZoneModel editingZone;
  final Function(ZoneWrapperModel, bool) onChangeZoneMode;
  final Function(ZoneModel, String) onChangeZoneName;
  final Function(ZoneWrapperModel, ZoneModel) toggleEditingZone;
  final Function(ZoneWrapperModel, ZoneModel) onEdtiMaxVolume;

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
            children: List.generate(
              zones.length,
              (idx) {
                final wrapper = zones[idx];

                return Watch(
                  (_) => Card.outlined(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Column(
                        children: [
                          ListTile(
                            title: Text("Zona ${idx + 1}"),
                            onTap: () => onChangeZoneMode(wrapper, !wrapper.isStereo),
                            leading: const Icon(Icons.home_filled),
                            trailing: AnimatedToggleSwitch.dual(
                              current: wrapper.isStereo,
                              first: true,
                              second: false,
                              onChanged: (value) => onChangeZoneMode(wrapper, value),
                              textBuilder: (value) => Text(
                                wrapper.mode.name.capitalize,
                                style: context.textTheme.titleSmall,
                              ),
                              height: 40,
                              indicatorSize: const Size.square(38),
                              iconBuilder: (value) => Icon(
                                value ? Icons.multitrack_audio_rounded : Icons.speaker_rounded,
                                color: context.colorScheme.onPrimary,
                              ),
                            ),
                          ),
                          AnimatedSize(
                            duration: Durations.medium2,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8.0),
                              child: Column(
                                key: ValueKey(wrapper.isStereo),
                                children: [
                                  Visibility(
                                    visible: wrapper.isStereo,
                                    child: ZoneDetailEditTile(
                                      zone: wrapper.stereoZone,
                                      wrapper: wrapper,
                                      hideEditButton: isEditing && editingZone.id != wrapper.id,
                                      isEditing: editingWrapper.id == wrapper.id && isEditing,
                                      onChangeZoneName: onChangeZoneName,
                                      toggleEditing: toggleEditingZone,
                                      maxVolume: wrapper.stereoZone.maxVolume,
                                      onTapEditMaxVolume: () => onEdtiMaxVolume(
                                        wrapper,
                                        wrapper.stereoZone,
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: wrapper.isStereo == false,
                                    child: ZoneDetailEditTile(
                                      label: wrapper.monoZones.left.id,
                                      zone: wrapper.monoZones.left,
                                      wrapper: wrapper,
                                      hideEditButton: isEditing && editingZone.id != wrapper.monoZones.left.id,
                                      isEditing: editingZone.id == wrapper.monoZones.left.id && isEditing,
                                      onChangeZoneName: onChangeZoneName,
                                      toggleEditing: toggleEditingZone,
                                      maxVolume: wrapper.monoZones.left.maxVolume,
                                      onTapEditMaxVolume: () => onEdtiMaxVolume(
                                        wrapper,
                                        wrapper.monoZones.left,
                                      ),
                                    ),
                                  ),
                                  8.asSpace,
                                  Visibility(
                                    visible: wrapper.isStereo == false,
                                    child: Watch(
                                      (_) => ZoneDetailEditTile(
                                        label: wrapper.monoZones.right.id,
                                        zone: wrapper.monoZones.right,
                                        wrapper: wrapper,
                                        hideEditButton: isEditing && editingZone.id != wrapper.monoZones.right.id,
                                        isEditing: editingZone.id == wrapper.monoZones.right.id && isEditing,
                                        onChangeZoneName: onChangeZoneName,
                                        toggleEditing: toggleEditingZone,
                                        maxVolume: wrapper.monoZones.right.maxVolume,
                                        onTapEditMaxVolume: () => onEdtiMaxVolume(
                                          wrapper,
                                          wrapper.monoZones.right,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
