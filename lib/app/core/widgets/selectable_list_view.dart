import 'package:flutter/material.dart';
import 'package:routefly/routefly.dart';

import '../models/selectable_model.dart';

class SelectableListView<T extends SelectableModel> extends StatelessWidget {
  const SelectableListView({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.onSelect,
    this.showSelectedIndicator = true,
  });

  final List<T> options;
  final T selectedOption;
  final bool showSelectedIndicator;
  final Function(T) onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: options.length,
      itemBuilder: (_, index) {
        final current = options[index];

        return ListTile(
          title: Text(current.label),
          trailing: Visibility(
            visible: showSelectedIndicator && selectedOption.label == current.label,
            child: const Icon(Icons.check_rounded),
          ),
          onTap: () {
            onSelect(current);
            Routefly.pop(context);
          },
        );
      },
    );
  }
}
