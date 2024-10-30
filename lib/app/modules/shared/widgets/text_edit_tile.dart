import 'package:flutter/material.dart';
import 'package:multiroom/app/core/models/zone_wrapper_model.dart';

import '../../../core/extensions/build_context_extensions.dart';
import '../../../core/extensions/number_extensions.dart';

class TextEditTile extends StatelessWidget {
  const TextEditTile({
    super.key,
    required this.itemId,
    required this.initialValue,
    required this.isEditing,
    required this.onChangeValue,
    this.toggleZoneVisible,
    required this.toggleEditing,
    required this.hideEditButton,
    this.hideZone
  });

  final String itemId;
  final String initialValue;
  final bool isEditing;
  final Function(String, String) onChangeValue;
  final Function()? toggleZoneVisible;
  final Function(String) toggleEditing;
  final bool hideEditButton;
  final bool? hideZone;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
         AnimatedSize(
          duration: Durations.short3,
          child: Visibility(
            visible: hideZone != null,
            child: IconButton(
              onPressed: () => toggleZoneVisible!(),
              icon: AnimatedSwitcher(
                duration: Durations.short3,
                child: Icon(
                  hideZone != null && hideZone! ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                ),
              ),
            ),
          ),
        ),
        6.asSpace,
        Expanded(
          child: TextFormField(
            enabled: isEditing,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: itemId,
            ),
            initialValue: initialValue,
            onChanged: (value) => onChangeValue(itemId, value),
            style: context.textTheme.titleSmall,
          ),
        ),
        12.asSpace,
        AnimatedSize(
          duration: Durations.short3,
          child: Visibility(
            visible: hideEditButton == false,
            child: IconButton(
              onPressed: () => toggleEditing(itemId),
              icon: AnimatedSwitcher(
                duration: Durations.short3,
                child: Icon(
                  key: ValueKey(isEditing),
                  isEditing ? Icons.check_rounded : Icons.edit_rounded,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
