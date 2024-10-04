import 'dart:math';

import 'package:another_xlider/another_xlider.dart';
import 'package:another_xlider/models/handler.dart';
import 'package:another_xlider/models/slider_step.dart';
import 'package:another_xlider/models/tooltip/tooltip.dart';
import 'package:another_xlider/models/trackbar.dart';
import 'package:flutter/material.dart';

import '../../../core/enums/mono_side.dart';
import '../../../core/extensions/build_context_extensions.dart';
import '../../../core/models/equalizer_model.dart';
import '../../../core/models/frequency.dart';
import '../../../core/models/zone_model.dart';
import '../../widgets/equalizer_card.dart';
import '../../widgets/slider_card.dart';

class ZoneControls extends StatefulWidget {
  const ZoneControls({
    super.key,
    required this.equalizers,
    required this.currentZone,
    required this.currentEqualizer,
    required this.onChangeVolume,
    required this.onChangeBalance,
    required this.onChangeEqualizer,
    required this.onUpdateFrequency,
  });

  final List<EqualizerModel> equalizers;
  final ZoneModel currentZone;
  final EqualizerModel currentEqualizer;
  final Function(int) onChangeVolume;
  final Function(int) onChangeBalance;
  final Function(Frequency) onUpdateFrequency;
  final Function() onChangeEqualizer;

  @override
  State<ZoneControls> createState() => _ZoneControlsState();
}

class _ZoneControlsState extends State<ZoneControls> {
  double _value = 50.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedSwitcher(
          duration: Durations.short4,
          child: SliderCard(
            key: ValueKey(widget.currentZone.name),
            title: "Volume",
            caption: "${min(widget.currentZone.volume, 100)}%",
            value: min(widget.currentZone.volume, 100),
            onChanged: widget.onChangeVolume,
          ),
        ),
        AnimatedSize(
          duration: Durations.medium1,
          child: Visibility(
            visible: widget.currentZone.side == MonoSide.undefined,
            child: Card.outlined(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Text(
                      "Balanço",
                      style: context.textTheme.titleMedium,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedOpacity(
                          duration: Durations.short2,
                          opacity: 1 - (widget.currentZone.balance.toDouble().abs() / 100),
                          child: Text(
                            "L",
                            style: context.textTheme.headlineSmall!.copyWith(
                              fontWeight: FontWeight.w900,
                              color: context.colorScheme.primary,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: FlutterSlider(
                              values: [_value],
                              min: 0,
                              max: 100,
                              centeredOrigin: true,
                              step: const FlutterSliderStep(step: 5),
                              trackBar: FlutterSliderTrackBar(
                                activeTrackBarHeight: 5,
                                inactiveTrackBarHeight: 4,
                                activeTrackBar: BoxDecoration(color: context.colorScheme.primary),
                                inactiveTrackBar: BoxDecoration(color: context.colorScheme.primary.withOpacity(.24)),
                              ),
                              onDragging: (handlerIndex, lowerValue, upperValue) {
                                widget.onChangeBalance(lowerValue.toInt());
                                setState(() {
                                  _value = lowerValue;
                                });
                              },
                              handlerHeight: 20,
                              handlerWidth: 20,
                              handler: FlutterSliderHandler(
                                decoration: BoxDecoration(
                                  color: context.colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Container(),
                              ),
                              tooltip: FlutterSliderTooltip(
                                custom: (value) => Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: context.colorScheme.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "${(100 - _value).toInt()} | ${(_value.toInt())}",
                                    style: context.textTheme.labelLarge!.copyWith(
                                      color: context.colorScheme.onPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        AnimatedOpacity(
                          duration: Durations.short2,
                          opacity: widget.currentZone.balance.toDouble().abs() / 100,
                          child: Text(
                            "R",
                            style: context.textTheme.headlineSmall!.copyWith(
                              fontWeight: FontWeight.w900,
                              color: context.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        EqualizerCard(
          equalizers: widget.equalizers,
          currentEqualizer: widget.currentEqualizer,
          onChangeEqualizer: widget.onChangeEqualizer,
          onUpdateFrequency: widget.onUpdateFrequency,
        ),
      ],
    );
  }
}
