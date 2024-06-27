import 'package:flutter/material.dart';

import '../../core/extensions/build_context_extensions.dart';
import '../../core/extensions/number_extensions.dart';

class IconTitle extends StatelessWidget {
  const IconTitle({
    super.key,
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon),
        12.asSpace,
        Text(
          title,
          style: context.textTheme.titleLarge,
        ),
      ],
    );
  }
}
