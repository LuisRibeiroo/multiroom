import 'package:flutter/material.dart';

import '../../core/enums/mono_side.dart';
import '../../core/models/equalizer_model.dart';
import '../../core/models/frequency.dart';
import '../../core/models/zone_model.dart';
import 'equalizer_card.dart';
import 'slider_card.dart';

class DeviceControls extends StatelessWidget {
  const DeviceControls({
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
  Widget build(BuildContext context) {
    return Card.filled(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          children: [
            AnimatedSwitcher(
              duration: Durations.short4,
              child: SliderCard(
                key: ValueKey(currentZone.name),
                title: "Volume",
                caption: "${currentZone.volume}%",
                value: currentZone.volume,
                onChanged: onChangeVolume,
              ),
            ),
            AnimatedSize(
              duration: Durations.medium1,
              child: Visibility(
                visible: currentZone.isEmpty == false && currentZone.side == MonoSide.undefined,
                child: SliderCard(
                  title: "Balanço",
                  min: 0,
                  max: 100,
                  caption: "${currentZone.balance}",
                  value: currentZone.balance,
                  onChanged: onChangeBalance,
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
        ),
      ),
    );
  }
}
