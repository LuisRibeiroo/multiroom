import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import 'device_model.dart';
import 'equalization_model.dart';
import 'mocks.dart';

class DeviceInfoPage extends StatefulWidget {
  const DeviceInfoPage({
    super.key,
    required this.device,
  });

  final DeviceModel device;

  @override
  State<DeviceInfoPage> createState() => _DeviceInfoPageState();
}

class _DeviceInfoPageState extends State<DeviceInfoPage> {
  final volume = 50.0.toSignal();
  final balance = 0.0.toSignal();
  final isMuted = false.toSignal();
  final isEditingVolume = false.toSignal();
  final isEditingBalance = false.toSignal();

  @override
  void initState() {
    super.initState();

    selectedEqualization.value = equalizations.first;
  }

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: Theme.of(context).sliderTheme.copyWith(
            inactiveTrackColor:
                Theme.of(context).colorScheme.primary.withAlpha(60),
          ),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.device.name),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(0),
            child: Row(
              children: [
                const SizedBox(width: 75),
                Text(
                  widget.device.zone,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 2,
                  height: 15,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Text(
                  widget.device.input,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
          ),
        ),
        body: Watch(
          (context) => SafeArea(
            child: Card.filled(
              margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: Row(
                        children: [
                          Text(
                            "Volume",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          AnimatedSwitcher(
                            duration: Durations.medium3,
                            child: isEditingVolume.value
                                ? Padding(
                                    padding: const EdgeInsets.only(left: 20.0),
                                    child: Text(
                                      "${volume.value.round()}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                      subtitle: Slider(
                        value: volume.value,
                        onChanged: volume.set,
                        min: 0,
                        max: 100,
                        divisions: 100,
                        onChangeStart: (_) => isEditingVolume.set(true),
                        onChangeEnd: (_) => isEditingVolume.set(false),
                      ),
                      trailing: IconButton.filledTonal(
                        color: Colors.black,
                        onPressed: () {
                          isMuted.set(!isMuted.value);

                          if (isMuted.value) {
                            volume.set(0);
                          } else {
                            volume.set(50);
                          }
                        },
                        icon: Watch(
                          (_) => AnimatedSwitcher(
                            duration: Durations.medium1,
                            child: Icon(
                              key: ValueKey(isMuted.value),
                              isMuted.value
                                  ? Icons.volume_mute_rounded
                                  : Icons.volume_up_rounded,
                            ),
                          ),
                        ),
                      ),
                    ),
                    ListTile(
                      title: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Balanço",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          AnimatedSwitcher(
                            duration: Durations.medium3,
                            child: isEditingBalance.value
                                ? Padding(
                                    padding: const EdgeInsets.only(left: 20.0),
                                    child: Text(
                                      "${balance.value.round()}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                      subtitle: Slider(
                        value: balance.value,
                        onChanged: balance.set,
                        min: -100,
                        max: 100,
                        divisions: 1000,
                        // label: "${balance.value.round()}",
                        onChangeStart: (_) => isEditingBalance.set(true),
                        onChangeEnd: (_) => isEditingBalance.set(false),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Watch(
                      (_) => EqualizerCard(
                        equalization: selectedEqualization.value!,
                        onEqualizationChanged: selectedEqualization.set,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EqualizerCard extends StatelessWidget {
  const EqualizerCard({
    super.key,
    required this.equalization,
    required this.onEqualizationChanged,
  });

  final EqualizationModel equalization;
  final Function(EqualizationModel) onEqualizationChanged;

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Watch(
          (_) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Equalizador",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        equalization.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  IconButton.filledTonal(
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      builder: (_) => SelectEqualizationBottomSheet(
                        selectedEqualization: selectedEqualization.value!,
                        onEqualizationChanged: selectedEqualization.set,
                      ),
                    ),
                    icon: const Icon(Icons.track_changes_rounded),
                  )
                ],
              ),
              const Divider(),
              SizedBox(
                height: 200,
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        children: List.generate(
                          11,
                          (index) => Row(
                            children: [
                              Text(
                                "${(10 - index) * 10}",
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall!
                                    .copyWith(fontSize: 8),
                              ),
                              Expanded(
                                child: Divider(
                                  height: 14,
                                  color: Theme.of(context)
                                      .dividerColor
                                      .withAlpha(60),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 24),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: equalization.values.length,
                        itemBuilder: (_, index) => Column(
                          children: [
                            Expanded(
                              child: SizedBox(
                                child: RotatedBox(
                                  quarterTurns: 3,
                                  child: Slider(
                                    value: equalization.values[index]
                                        .watch(context),
                                    onChanged: equalization.values[index].set,
                                    min: 0,
                                    max: 100,
                                    divisions: 100 ~/ 5,
                                  ),
                                ),
                              ),
                            ),
                            // Flexible(
                            //   child: FlutterSlider(
                            //     axis: Axis.vertical,
                            //     rtl: true,
                            //     values: const [100],
                            //     max: 100,
                            //     min: 0,
                            //     step: const FlutterSliderStep(step: 5),
                            //     tooltip: FlutterSliderTooltip(disabled: true),
                            //     handlerHeight: 36,
                            //     handlerWidth: 18,
                            //     selectByTap: false,
                            //     onDragging:
                            //         (handlerIndex, lowerValue, upperValue) {
                            //       equalization.values[index].set(lowerValue);
                            //     },
                            //     handlerAnimation:
                            //         const FlutterSliderHandlerAnimation(
                            //       scale: 1,
                            //     ),
                            //     handler: handler(context),
                            //     trackBar: trackBar(context),
                            //   ),
                            // ),
                            Text(
                              "${equalization.values[index].watch(context).round()}",
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SelectEqualizationBottomSheet extends StatelessWidget {
  const SelectEqualizationBottomSheet({
    super.key,
    required this.selectedEqualization,
    required this.onEqualizationChanged,
  });

  final EqualizationModel selectedEqualization;
  final Function(EqualizationModel p1) onEqualizationChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 36.0, left: 18.0, right: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Selecione uma equalização padrão",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Flexible(
            child: ListView.builder(
              itemCount: equalizations.length,
              itemBuilder: (_, idx) => RadioListTile(
                groupValue: selectedEqualization,
                value: equalizations[idx],
                title: Text(equalizations[idx].name),
                onChanged: (_) {
                  onEqualizationChanged(equalizations[idx]);
                  Navigator.of(context).pop();
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
