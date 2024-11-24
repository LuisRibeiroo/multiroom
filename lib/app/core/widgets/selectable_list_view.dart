import 'package:flutter/material.dart';
import 'package:routefly/routefly.dart';

import '../../modules/widgets/icon_title.dart';
import '../extensions/string_extensions.dart';
import '../models/selectable_model.dart';

class SelectableListView<T extends SelectableModel> extends StatelessWidget {
  const SelectableListView({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.onSelect,
    this.title,
    this.icon,
    this.showSelectedIndicator = true,
    this.showSubtitle = false,
    this.onTapEdit,
  });

  final String? title;
  final IconData? icon;
  final List<T> options;
  final bool showSubtitle;
  final T selectedOption;
  final bool showSelectedIndicator;
  final Function(T) onSelect;
  final Function()? onTapEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Visibility(
          visible: title.isNotNullOrEmpty && icon != null,
          child: Stack(
            children: [
              IconTitle(
                title: title ?? "",
                icon: icon ?? Icons.settings_rounded,
              ),
              Visibility(
                visible: onTapEdit != null,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: IconButton(
                      icon: const Icon(Icons.edit_rounded),
                      onPressed: onTapEdit?.call,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Flexible(
          child: ListView.builder(
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
          ),
        ),
      ],
    );
  }
}
