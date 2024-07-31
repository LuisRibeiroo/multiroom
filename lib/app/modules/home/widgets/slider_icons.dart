import 'package:flutter/material.dart';

import '../../../core/extensions/build_context_extensions.dart';
import '../../../core/extensions/string_extensions.dart';

class SliderIcons extends StatelessWidget {
  const SliderIcons({
    super.key,
    required this.value,
    required this.onChanged,
    this.title,
    this.min = 0,
    this.max = 100,
    this.divisions = 100,
  });

  final String? title;
  final num value;
  final Function(int) onChanged;
  final int min;
  final int max;
  final int divisions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Visibility(
            visible: title.isNotNullOrEmpty,
            child: Text(
              title ?? "",
              style: context.textTheme.titleMedium,
            ),
          ),
          Row(
            children: [
              const Icon(Icons.volume_down_rounded),
              Expanded(
                child: Slider(
                  value: value.toDouble(),
                  onChanged: (v) => onChanged(v.toInt()),
                  min: min.toDouble(),
                  max: max.toDouble(),
                  divisions: divisions,
                  label: value.toString(),
                ),
              ),
              const Icon(Icons.volume_up_rounded),
            ],
          ),
        ],
      ),
    );
  }
}
