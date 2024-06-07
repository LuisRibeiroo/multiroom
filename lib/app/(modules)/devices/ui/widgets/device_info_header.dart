import 'package:flutter/material.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';

import '../../../../core/extensions/build_context_extensions.dart';
import '../../../../core/extensions/number_extensions.dart';
import '../../../../core/models/channel_model.dart';
import '../../../../core/models/zone_model.dart';
import '../../interactor/models/device_model.dart';

class DeviceInfoHeader extends StatefulWidget {
  const DeviceInfoHeader({
    super.key,
    required this.device,
    required this.currentZone,
    required this.currentChannel,
    required this.onChangeZone,
    required this.onChangeChannel,
  });

  final DeviceModel device;
  final ZoneModel currentZone;
  final ChannelModel currentChannel;
  final Function(ZoneModel) onChangeZone;
  final Function(ChannelModel) onChangeChannel;

  @override
  State<DeviceInfoHeader> createState() => _DeviceInfoHeaderState();
}

class _DeviceInfoHeaderState extends State<DeviceInfoHeader> {
  final _zoneController = MultiSelectController<int>();
  final _channelController = MultiSelectController<int>();
  late final List<ValueItem<int>> _zoneOptions;
  late final List<ValueItem<int>> _channelOptions;

  @override
  void initState() {
    super.initState();

    _zoneOptions = List.generate(
      widget.device.zones.length,
      (idx) => ValueItem(
        label: widget.device.zones[idx].name,
        value: idx,
      ),
    );

    _channelOptions = List.generate(
      widget.currentZone.channels.length,
      (idx) => ValueItem(
        label: widget.currentZone.channels[idx].name,
        value: idx,
      ),
    );

    _zoneController.setOptions(_zoneOptions);
    if (_zoneOptions.isNotEmpty) {
      _zoneController.setSelectedOptions([_zoneOptions.first]);
    }

    _channelController.setOptions(_channelOptions);
    if (_channelOptions.isNotEmpty) {
      _channelController.setSelectedOptions([_channelOptions.first]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    widget.device.name,
                    style: context.textTheme.headlineSmall,
                  ),
                ),
                12.asSpace,
                Flexible(
                  flex: 2,
                  child: Column(
                    children: [
                      MultiSelectDropDown(
                        fieldBackgroundColor: context.colorScheme.surface,
                        optionsBackgroundColor:
                            context.colorScheme.surface.withOpacity(.9),
                        selectionType: SelectionType.single,
                        hint: "Selecione a zona",
                        controller: _zoneController,
                        options: _zoneOptions,
                        suffixIcon:
                            const Icon(Icons.keyboard_arrow_down_rounded),
                        clearIcon: const Icon(Icons.clear, size: 0),
                        onOptionSelected: (options) {
                          widget.onChangeZone(
                              widget.device.zones[options.first.value!]);
                        },
                        singleSelectItemStyle:
                            context.textTheme.titleSmall!.copyWith(
                          color: context.colorScheme.onSurface,
                        ),
                        selectedOptionIcon: Icon(
                          Icons.check_rounded,
                          color: context.colorScheme.inversePrimary,
                        ),
                      ),
                      8.asSpace,
                      MultiSelectDropDown(
                        fieldBackgroundColor: context.colorScheme.surface,
                        optionsBackgroundColor:
                            context.colorScheme.surface.withOpacity(.9),
                        hint: "Selecione o input",
                        selectionType: SelectionType.single,
                        controller: _channelController,
                        options: _channelOptions,
                        suffixIcon:
                            const Icon(Icons.keyboard_arrow_down_rounded),
                        clearIcon: const Icon(Icons.clear, size: 0),
                        onOptionSelected: (options) {
                          widget.onChangeChannel(widget
                              .currentZone.channels[options.first.value!]);
                        },
                        singleSelectItemStyle:
                            context.textTheme.titleSmall!.copyWith(
                          color: context.colorScheme.onSurface,
                        ),
                        selectedOptionIcon: Icon(
                          Icons.check_rounded,
                          color: context.colorScheme.inversePrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
