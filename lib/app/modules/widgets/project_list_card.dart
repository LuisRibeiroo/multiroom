import 'package:flutter/material.dart';

import '../../core/extensions/build_context_extensions.dart';
import '../../core/extensions/number_extensions.dart';
import '../../core/models/device_model.dart';
import '../../core/models/project_model.dart';
import '../scanner/widgets/device_list_tile.dart';

class ProjectListCard extends StatelessWidget {
  const ProjectListCard({
    super.key,
    required this.project,
    required this.onTapConfigDevice,
    required this.onTapRemoveProject,
  });

  final ProjectModel project;
  final Function(DeviceModel) onTapConfigDevice;
  final Function(ProjectModel) onTapRemoveProject;

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.group_work_rounded),
                12.asSpace,
                Expanded(
                  child: Text(
                    project.name,
                    style: context.textTheme.headlineSmall,
                  ),
                ),
                12.asSpace,
                IconButton.outlined(
                  icon: const Icon(Icons.delete_rounded),
                  onPressed: () {
                    onTapRemoveProject(project);
                  },
                ),
              ],
            ),
            8.asSpace,
            ...List.generate(
              project.devices.length,
              (idx) => DeviceListTile(
                device: project.devices[idx],
                onTapConfigDevice: onTapConfigDevice,
              ),
            )
          ],
        ),
      ),
    );
  }
}
