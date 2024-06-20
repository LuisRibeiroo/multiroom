import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../../../core/extensions/build_context_extensions.dart';
import '../../../core/extensions/string_extensions.dart';
import '../../../core/models/zone_group_model.dart';
import '../../../core/models/zone_model.dart';

class GroupsExpandableCard extends StatelessWidget {
  const GroupsExpandableCard({
    super.key,
    required this.groups,
    required this.onTapAddGroup,
    required this.onTapRemoveZone,
    required this.expandableController,
  });

  final ExpandableController expandableController;
  final List<ZoneGroupModel> groups;
  final Function(ZoneGroupModel) onTapAddGroup;
  final Function(ZoneGroupModel, ZoneModel) onTapRemoveZone;

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
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(group.name.capitalize),
                            // subtitle: const Text("Input 2"),
                            leading: const Icon(Icons.group_work_rounded),
                            trailing: const Icon(Icons.add_link_rounded),
                            onTap: () => onTapAddGroup(group),
                          ),
                          Visibility(
                            visible: group.zones.isNotEmpty,
                            child: Column(
                              children: [
                                const Divider(indent: 12, endIndent: 12),
                                AnimatedSize(
                                  duration: Durations.medium2,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12.0),
                                    child: Column(
                                      key: ValueKey("${group.name}_${group.zones.length}"),
                                      children: List.generate(group.zones.length, (idx) {
                                        final zone = group.zones[idx];

                                        return ListTile(
                                          title: Text(zone.name),
                                          trailing: const Icon(Icons.remove_circle_rounded),
                                          onTap: () => onTapRemoveZone(group, zone),
                                        );
                                      }),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
