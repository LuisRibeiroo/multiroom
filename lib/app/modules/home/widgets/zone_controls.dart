import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/enums/mono_side.dart';
import '../../../core/extensions/build_context_extensions.dart';
import '../../../core/models/equalizer_model.dart';
import '../../../core/models/frequency.dart';
import '../../../core/models/zone_model.dart';
import '../../widgets/equalizer_card.dart';
import '../../widgets/slider_card.dart';

class ZoneControls extends StatelessWidget {
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

  final _minBalance = 0.0;
  final _maxBalance = 100.0;

  double _normalizedValue(double current) => (current - _minBalance) / (_maxBalance - _minBalance);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedSwitcher(
          duration: Durations.short4,
          child: SliderCard(
            key: ValueKey(currentZone.name),
            title: "Volume",
            caption: "${min(currentZone.volume, 100)}%",
            value: min(currentZone.volume, 100),
            onChanged: onChangeVolume,
          ),
        ),
        AnimatedSize(
          duration: Durations.medium1,
          child: Visibility(
            visible: currentZone.side == MonoSide.undefined,
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
                      children: [
                        AnimatedOpacity(
                          duration: Durations.short2,
                          opacity: 1 - _normalizedValue(currentZone.balance.toDouble()),
                          child: Text(
                            "L",
                            style: context.textTheme.headlineSmall!.copyWith(
                              fontWeight: FontWeight.w900,
                              color: context.colorScheme.primary,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Slider(
                            value: currentZone.balance.toDouble(),
                            onChanged: (v) => onChangeBalance(v.toInt()),
                            min: _minBalance,
                            max: _maxBalance,
                            divisions: _maxBalance ~/ 5,
                            label: "${100 - currentZone.balance} | ${(currentZone.balance)}",
                            inactiveColor: context.colorScheme.primary,
                          ),
                        ),
                        AnimatedOpacity(
                          duration: Durations.short2,
                          opacity: _normalizedValue(currentZone.balance.toDouble()),
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
          equalizers: equalizers,
          currentEqualizer: currentEqualizer,
          onChangeEqualizer: onChangeEqualizer,
          onUpdateFrequency: onUpdateFrequency,
        ),
      ],
    );
  }
}
