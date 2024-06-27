import 'package:flutter/material.dart';
import '../../core/extensions/number_extensions.dart';

class IconTextTile extends StatelessWidget {
  const IconTextTile({
    super.key,
    required this.icon,
    required this.text,
    this.style,
  });

  final IconData icon;
  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 20,
        ),
        8.asSpace,
        Flexible(
          child: Text(
            text,
            style: style,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
