import 'package:flutter/material.dart';

import '../../core/extensions/build_context_extensions.dart';

class SliderCard extends StatelessWidget {
  const SliderCard({
    super.key,
    required this.title,
    required this.caption,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 100,
    this.divisions = 100,
  });

  final String title;
  final String caption;
  final num value;
  final Function(int) onChanged;
  final int min;
  final int max;
  final int divisions;

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(
              title,
              style: context.textTheme.titleMedium,
            ),
            Slider(
              value: value.toDouble(),
              onChanged: (v) => onChanged(v.toInt()),
              min: min.toDouble(),
              max: max.toDouble(),
              divisions: divisions,
              label: value.toString(),
            ),
            Text(
              caption,
              style: context.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
