import 'package:flutter/material.dart';

class AppSwitch extends StatelessWidget {
  const AppSwitch({
    super.key,
    required this.value,
    this.onChangeActive,
    this.labels,
    this.icons,
  });

  final bool value;
  final Function(bool)? onChangeActive;
  final ({String onLabel, String offLabel})? labels;
  final ({IconData onIcon, IconData offIcon})? icons;

  @override
  Widget build(BuildContext context) {
    // return AnimatedToggleSwitch.dual(
    //   current: value,
    //   first: false,
    //   second: true,
    //   onChanged: onChangeActive,
    //   height: 34,
    //   indicatorSize: const Size.square(32),
    //   textBuilder: (value) => Text(
    //     value ? labels?.onLabel ?? "ON" : labels?.offLabel ?? "OFF",
    //     style: context.textTheme.titleSmall,
    //   ),
    //   iconBuilder: (value) => Icon(
    //     value ? icons?.onIcon ?? Icons.power_rounded : icons?.offIcon ?? Icons.power_off_rounded,
    //     color: context.colorScheme.onPrimary,
    //   ),
    // );

    return Transform.scale(
      scaleX: 0.8,
      scaleY: 0.8,
      child: Switch(
        value: value,
        onChanged: onChangeActive,
      ),
    );
  }
}
