import 'package:flutter/material.dart';
import '../models/selectable_model.dart';
import 'package:routefly/routefly.dart';

class BottomSheetSelector<T extends SelectableModel> extends StatelessWidget {
  const BottomSheetSelector({
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
      padding: const EdgeInsets.only(top: 12.0),
      itemCount: options.length,
      itemBuilder: (_, index) {
        final current = options[index];

        return ListTile(
          title: Text(current.label),
          trailing: Visibility(
            visible: showSelectedIndicator && selectedOption == current,
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
