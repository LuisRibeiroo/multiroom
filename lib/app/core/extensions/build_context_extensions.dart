import 'package:flutter/material.dart';
import 'package:multiroom/app/core/extensions/number_extensions.dart';

extension ContextExt on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  IconThemeData get iconTheme => theme.iconTheme;
  Size get sizeOf => MediaQuery.sizeOf(this);
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  Future<T?> showCustomModalBottomSheet<T>({
    required Widget child,
    bool isScrollControlled = true,
    bool isDismissible = true,
  }) async {
    final maxHeight = isScrollControlled ? .8 : .5;

    return await showModalBottomSheet<T>(
      context: this,
      isDismissible: isDismissible,
      isScrollControlled: isScrollControlled,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SizedBox(
        width: sizeOf.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            22.asSpace,
            ConstrainedBox(
              constraints: BoxConstraints(
                // minHeight: size.height * .2,
                maxHeight: sizeOf.height * maxHeight - 8,
              ),
              child: SafeArea(
                child: Padding(
                  padding: mediaQuery.viewInsets,
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
