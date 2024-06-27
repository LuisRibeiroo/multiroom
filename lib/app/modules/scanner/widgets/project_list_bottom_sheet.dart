import 'package:flutter/material.dart';

import '../../../core/extensions/build_context_extensions.dart';
import '../../../core/extensions/number_extensions.dart';
import '../../../core/models/project_model.dart';
import '../../../core/widgets/app_button.dart';

class ProjectListBottomSheet extends StatelessWidget {
  const ProjectListBottomSheet({
    super.key,
    required this.projects,
    required this.onTapAddProject,
    required this.onTapProject,
  });

  final List<ProjectModel> projects;
  final Function() onTapAddProject;
  final Function(ProjectModel) onTapProject;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.group_work_rounded),
              12.asSpace,
              Text(
                "Projetos",
                style: context.textTheme.titleLarge,
              ),
            ],
          ),
          18.asSpace,
          SizedBox(
            width: context.sizeOf.width / 1.5,
            child: AppButton(
              type: ButtonType.secondary,
              text: "Novo",
              trailing: const Icon(Icons.add_rounded),
              onPressed: onTapAddProject,
            ),
          ),
          24.asSpace,
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: projects.length,
              itemBuilder: (_, index) {
                final current = projects[index];

                return ListTile(
                  title: Text(current.name),
                  trailing: const Icon(Icons.arrow_forward_rounded),
                  onTap: () => onTapProject(current),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
