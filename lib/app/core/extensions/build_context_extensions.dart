import 'package:flutter/material.dart';

extension ContextExt on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  Future<T?> showCustomModalBottomSheet<T>({
    required Widget child,
    bool isScrollControlled = true,
    bool isDismissible = true,
  }) {
    final maxHeight = isScrollControlled ? .8 : .5;

    return showModalBottomSheet<T>(
      context: this,
      isDismissible: isDismissible,
      isScrollControlled: isScrollControlled,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 22),
            child: Container(
              height: 4,
              width: 32,
              decoration: BoxDecoration(
                color: Theme.of(this).colorScheme.onSurface,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(12),
                  right: Radius.circular(12),
                ),
              ),
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(this).size.height * .3,
              maxHeight: MediaQuery.of(this).size.height * maxHeight,
            ),
            child: Padding(
              padding: MediaQuery.of(this).viewInsets,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
