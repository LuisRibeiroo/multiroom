import 'dart:async';

import 'package:flutter/material.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:signals/signals_flutter.dart';

import '../../core/extensions/build_context_extensions.dart';
import '../../core/extensions/number_extensions.dart';
import '../../core/models/equalizer_model.dart';
import '../../core/models/frequency.dart';

class EqualizerCard extends StatefulWidget {
  const EqualizerCard({
    super.key,
    required this.equalizers,
    required this.currentEqualizer,
    required this.onChangeEqualizer,
    required this.onUpdateFrequency,
    required this.equalizerController,
  });

  final List<EqualizerModel> equalizers;
  final EqualizerModel currentEqualizer;
  final Function(String) onChangeEqualizer;
  final Function(Frequency) onUpdateFrequency;
  final MultiSelectController<int> equalizerController;

  @override
  State<EqualizerCard> createState() => _EqualizerCardState();
}

class _EqualizerCardState extends State<EqualizerCard> {
  @override
  void initState() {
    super.initState();

    scheduleMicrotask(() {
      if (widget.equalizerController.options.isNotEmpty) {
        widget.equalizerController.setSelectedOptions(
          [
            widget.equalizerController.options.firstWhere(
              (value) => value.label == widget.currentEqualizer.name,
              orElse: () => widget.equalizerController.options.first,
            ),
          ],
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Equalizador",
              style: context.textTheme.titleLarge,
            ),
            12.asSpace,
            MultiSelectDropDown(
              fieldBackgroundColor: context.colorScheme.surface,
              optionsBackgroundColor: context.colorScheme.surface.withOpacity(.9),
              dropdownBackgroundColor: context.colorScheme.surface.withOpacity(.9),
              selectionType: SelectionType.single,
              hint: "Selecione um equalizador",
              controller: widget.equalizerController,
              options: widget.equalizerController.options,
              suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
              clearIcon: const Icon(Icons.clear, size: 0),
              onOptionSelected: (options) {
                widget.onChangeEqualizer(options.first.label);
              },
              singleSelectItemStyle: context.textTheme.titleSmall!.copyWith(
                color: context.colorScheme.onSurface,
              ),
              selectedOptionIcon: Icon(
                Icons.check_rounded,
                color: context.colorScheme.inversePrimary,
              ),
            ),
            18.asSpace,
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.currentEqualizer.frequencies.length,
                  itemBuilder: (_, index) {
                    final current = widget.currentEqualizer.frequencies[index];

                    return Column(
                      children: [
                        Text(
                          "${current.name}db",
                          style: context.textTheme.bodyMedium,
                        ),
                        Watch(
                          (_) => Expanded(
                            child: SizedBox(
                              child: RotatedBox(
                                quarterTurns: 3,
                                child: Slider(
                                  min: -100,
                                  max: 100,
                                  divisions: 200 ~/ 5,
                                  value: current.value.toDouble(),
                                  onChanged: (v) {
                                    widget.onUpdateFrequency(
                                      current.copyWith(value: v.toInt()),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        Text(
                          "${current.value.round()}",
                          style: context.textTheme.labelLarge,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
