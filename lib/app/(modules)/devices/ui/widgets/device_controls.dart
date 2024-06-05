import 'package:flutter/material.dart';
import 'package:multiroom/app/(modules)/devices/ui/widgets/equalizer_card.dart';

import '../../../../core/models/equalizer_model.dart';
import '../../../../core/models/frequency.dart';
import '../../../../core/models/input_model.dart';
import '../../../../core/models/zone_model.dart';
import '../../interactor/models/device_model.dart';
import 'slider_card.dart';

class DeviceControls extends StatefulWidget {
  const DeviceControls({
    super.key,
    required this.equalizers,
    required this.device,
    required this.currentZone,
    required this.currentInput,
    required this.onChangeVolume,
    required this.onChangeBalance,
    required this.onChangeEqualizer,
    required this.onUpdateFrequency,
  });

  final List<EqualizerModel> equalizers;
  final DeviceModel device;
  final ZoneModel currentZone;
  final InputModel currentInput;
  final Function(double) onChangeVolume;
  final Function(double) onChangeBalance;
  final Function(int) onChangeEqualizer;
  final Function(EqualizerModel, Frequency) onUpdateFrequency;

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
              min: -100,
              caption: "${widget.currentZone.balance}",
              value: widget.currentZone.balance,
              onChanged: widget.onChangeBalance,
            ),
            EqualizerCard(
              device: widget.device,
              equalizers: widget.equalizers,
              currentEqualizer: widget.currentZone.equalizer,
              onChangeEqualizer: widget.onChangeEqualizer,
              onUpdateFrequency: widget.onUpdateFrequency,
            ),
          ],
        ),
      ),
    );
  }
}
