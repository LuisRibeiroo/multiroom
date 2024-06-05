import 'package:flutter/material.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:multiroom/app/(modules)/devices/interactor/models/device_model.dart';
import 'package:multiroom/app/core/extensions/number_extensions.dart';
import 'package:multiroom/app/core/models/frequency.dart';
import 'package:signals/signals_flutter.dart';

import '../../../../core/extensions/build_context_extensions.dart';
import '../../../../core/models/equalizer_model.dart';

class EqualizerCard extends StatefulWidget {
  const EqualizerCard({
    super.key,
    required this.device,
    required this.equalizers,
    required this.currentEqualizer,
    required this.onChangeEqualizer,
    required this.onUpdateFrequency,
  });

  final DeviceModel device;
  final List<EqualizerModel> equalizers;
  final EqualizerModel currentEqualizer;
  final Function(int) onChangeEqualizer;
  final Function(EqualizerModel, Frequency) onUpdateFrequency;

  @override
  State<EqualizerCard> createState() => _EqualizerCardState();
}

class _EqualizerCardState extends State<EqualizerCard> {
  final _equalizerController = MultiSelectController<int>();
  late final List<ValueItem<int>> _equalizerOptions;

  @override
  void initState() {
    super.initState();

    _equalizerOptions = List.generate(
      widget.equalizers.length,
      (idx) => ValueItem(
        label: widget.equalizers[idx].name,
        value: idx,
      ),
    );

    _equalizerController
      ..setOptions(_equalizerOptions)
      ..setSelectedOptions([_equalizerOptions.first]);
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
              style: Theme.of(context).textTheme.titleLarge,
            ),
            12.asSpace,
            MultiSelectDropDown(
              fieldBackgroundColor: context.colorScheme.surface,
              optionsBackgroundColor:
                  context.colorScheme.surface.withOpacity(.9),
              dropdownBackgroundColor:
                  context.colorScheme.surface.withOpacity(.9),
              selectionType: SelectionType.single,
              hint: "Selecione um equalizador",
              controller: _equalizerController,
              options: _equalizerOptions,
              suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
              clearIcon: const Icon(Icons.clear, size: 0),
              onOptionSelected: (options) {
                widget.onChangeEqualizer(options.first.value!);
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
                  itemBuilder: (_, index) => Column(
                    children: [
                      Text(
                        widget.currentEqualizer.frequencies[index].name,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Watch((context) {
                        return Expanded(
                          child: SizedBox(
                            child: RotatedBox(
                              quarterTurns: 3,
                              child: Slider(
                                min: 0,
                                max: 100,
                                divisions: 100 ~/ 5,
                                value: widget
                                    .currentEqualizer.frequencies[index].value
                                    .toDouble(),
                                onChanged: (v) {
                                  widget.onUpdateFrequency(
                                    widget.currentEqualizer,
                                    widget.currentEqualizer.frequencies[index]
                                        .copyWith(
                                      value: v.toInt(),
                                    ),
                                  );
                                },
                                // onChanged: (v) {
                                //   final f = widget
                                //       .currentEqualizer.frequencies[index];

                                //   final tempList = List<Frequency>.from(
                                //       widget.currentEqualizer.frequencies);

                                //   tempList[index] =
                                //       f.copyWith(value: v.toInt());

                                //   widget.onChangeEqualizer(
                                //     widget.currentEqualizer.copyWith(
                                //       frequencies: tempList,
                                //     ),
                                //   );
                                // },
                              ),
                            ),
                          ),
                        );
                      }),
                      Text(
                        "${widget.currentEqualizer.frequencies[index].value.round()}",
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
