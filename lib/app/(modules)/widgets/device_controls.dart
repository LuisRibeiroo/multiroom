import 'package:flutter/material.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';

import '../../core/models/equalizer_model.dart';
import '../../core/models/frequency.dart';
import '../../core/models/zone_model.dart';
import 'equalizer_card.dart';
import 'slider_card.dart';

class DeviceControls extends StatefulWidget {
  const DeviceControls({
    super.key,
    required this.equalizers,
    required this.currentZone,
    required this.currentEqualizer,
    required this.onChangeVolume,
    required this.onChangeBalance,
    required this.onChangeEqualizer,
    required this.onUpdateFrequency,
    required this.equalizerController,
  });

  final List<EqualizerModel> equalizers;
  final ZoneModel currentZone;
  final EqualizerModel currentEqualizer;
  final Function(int) onChangeVolume;
  final Function(int) onChangeBalance;
  final Function(String) onChangeEqualizer;
  final Function(Frequency) onUpdateFrequency;
  final MultiSelectController<int> equalizerController;

  @override
  State<DeviceControls> createState() => _DeviceControlsState();
}

class _DeviceControlsState extends State<DeviceControls> {
  @override
  Widget build(BuildContext context) {
    return Card.filled(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          children: [
            SliderCard(
              title: "Volume",
              caption: "${widget.currentZone.volume}%",
              value: widget.currentZone.volume,
              onChanged: widget.onChangeVolume,
            ),
            SliderCard(
              title: "Balanço",
              min: 0,
              max: 100,
              caption: "${widget.currentZone.balance}",
              value: widget.currentZone.balance,
              onChanged: widget.onChangeBalance,
            ),
            EqualizerCard(
              equalizers: widget.equalizers,
              currentEqualizer: widget.currentEqualizer,
              onChangeEqualizer: widget.onChangeEqualizer,
              onUpdateFrequency: widget.onUpdateFrequency,
              equalizerController: widget.equalizerController,
            ),
          ],
        ),
      ),
    );
  }
}
