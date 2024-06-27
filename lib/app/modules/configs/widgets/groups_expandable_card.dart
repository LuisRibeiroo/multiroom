import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import '../../../core/extensions/number_extensions.dart';
import 'package:signals/signals_flutter.dart';

import '../../../core/extensions/build_context_extensions.dart';
import '../../../core/extensions/string_extensions.dart';
import '../../../core/models/zone_group_model.dart';
import '../../../core/models/zone_model.dart';
import '../../../core/widgets/app_button.dart';

class GroupsExpandableCard extends StatelessWidget {
  const GroupsExpandableCard({
    super.key,
    required this.isEditing,
    required this.groups,
    required this.onTapAddGroup,
    required this.onTapRemoveZone,
    required this.expandableController,
    required this.toggleEditingGroup,
    required this.editingGroup,
    required this.onChangeGroupName,
  });

  final bool isEditing;
  final ExpandableController expandableController;
  final List<ZoneGroupModel> groups;
  final Function(ZoneGroupModel) onTapAddGroup;
  final Function(ZoneGroupModel, ZoneModel) onTapRemoveZone;
  final Function(ZoneGroupModel) toggleEditingGroup;
  final ZoneGroupModel editingGroup;
  final Function(ZoneGroupModel, String) onChangeGroupName;

  @override
  Widget build(BuildContext context) {
    return Watch(
      (_) => Card.filled(
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
              "Grupos",
              style: context.textTheme.titleMedium,
            ),
          ),
          collapsed: const SizedBox.shrink(),
          expanded: Padding(
            padding: const EdgeInsets.only(bottom: 12.0, left: 12, right: 12),
            child: Column(
              children: List.generate(
                groups.length,
                (idx) {
                  final group = groups[idx];

                  return Watch(
                    (_) => Card.outlined(
                      clipBehavior: Clip.hardEdge,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 12.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.home_work_rounded),
                                12.asSpace,
                                Expanded(
                                  child: TextFormField(
                                    enabled: isEditing && editingGroup.id == group.id,
                                    decoration: const InputDecoration(border: OutlineInputBorder()),
                                    initialValue: group.name.capitalize,
                                    style: context.textTheme.titleSmall,
                                    onChanged: (value) => onChangeGroupName(group, value),
                                  ),
                                ),
                                12.asSpace,
                                IconButton(
                                  onPressed: () => toggleEditingGroup(group),
                                  icon: AnimatedSwitcher(
                                    duration: Durations.short3,
                                    child: Icon(
                                      key: ValueKey("${group.id}$isEditing"),
                                      isEditing && editingGroup.id == group.id
                                          ? Icons.check_rounded
                                          : Icons.edit_rounded,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                AnimatedSize(
                                  duration: Durations.medium2,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12.0),
                                    child: Column(
                                      key: ValueKey("${group.name}_${group.zones.length}"),
                                      children: [
                                        8.asSpace,
                                        SizedBox(
                                          width: context.mediaQuery.size.width / 2,
                                          child: AppButton(
                                            type: ButtonType.secondary,
                                            text: "Adicionar zona",
                                            onPressed: () => onTapAddGroup(group),
                                            trailing: const Icon(Icons.add_link_rounded),
                                          ),
                                        ),
                                        8.asSpace,
                                        ...List.generate(group.zones.length, (idx) {
                                          final zone = group.zones[idx];

                                          return ListTile(
                                            title: Text(zone.name),
                                            trailing: const Icon(Icons.remove_circle_rounded),
                                            onTap: () => onTapRemoveZone(group, zone),
                                          );
                                        })
                                      ],
                                    ),
                                  ),
                                ),
                              ],
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
      ),
    );
  }
}
