import 'package:flutter/material.dart';

import '../../../core/extensions/build_context_extensions.dart';
import '../../../core/extensions/number_extensions.dart';
import '../../../core/widgets/app_button.dart';

class AddProjectBottomSheet extends StatelessWidget {
  const AddProjectBottomSheet({
    super.key,
    required this.projectName,
    required this.onChangeProjectName,
    required this.isNameValid,
    required this.onAddProject,
  });

  final String projectName;
  final Function(String) onChangeProjectName;
  final bool isNameValid;
  final Function() onAddProject;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Novo projeto",
            style: context.textTheme.titleLarge,
          ),
          12.asSpace,
          TextFormField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Nome",
              hintText: "Casa",
            ),
            initialValue: projectName,
            onChanged: onChangeProjectName,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: AppButton(
              text: "Adicionar",
              trailing: const Icon(Icons.check_rounded),
              onPressed: isNameValid ? onAddProject : null,
            ),
          ),
        ],
      ),
    );
  }
}
