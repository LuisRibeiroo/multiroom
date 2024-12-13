import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../../../../injector.dart';
import '../../../core/extensions/build_context_extensions.dart';
import '../../../core/extensions/number_extensions.dart';
import '../../../core/models/channel_model.dart';
import '../../../core/models/device_model.dart';
import '../../../core/models/zone_model.dart';
import '../../../core/widgets/selectable_list_view.dart';
import '../../widgets/icon_title.dart';
import '../interactor/edit_channels_bottom_sheet_controller.dart';

class EditChannelsBottomSheet extends StatefulWidget {
  const EditChannelsBottomSheet({
    super.key,
    required this.onSelect,
    required this.device,
    required this.zone,
  });

  final DeviceModel device;
  final ZoneModel zone;
  final Function(
    ChannelModel channel,
    ZoneModel zone,
    List<ChannelModel> channels,
  ) onSelect;

  @override
  State<EditChannelsBottomSheet> createState() => _EditChannelsBottomSheetState();
}

class _EditChannelsBottomSheetState extends State<EditChannelsBottomSheet> {
  final _controller = injector.get<EditChannelsBottomSheetController>();

  @override
  void initState() {
    super.initState();

    _controller.init(
      device: widget.device,
      zone: widget.zone,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }

        if (context.mounted) {
          Navigator.pop(context, _controller.shouldUpdate.value);
        }
      },
      canPop: false,
      child: Watch(
        (_) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                const IconTitle(
                  title: "Canais",
                  icon: Icons.music_note,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: AnimatedSwitcher(
                      duration: Durations.short3,
                      child: IconButton(
                        icon: AnimatedSwitcher(
                          duration: Durations.short3,
                          child: Icon(_controller.isEditMode.value ? Icons.check_rounded : Icons.edit_rounded),
                        ),
                        onPressed: _controller.toggleEditMode,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Flexible(
              child: AnimatedSwitcher(
                duration: Durations.short3,
                child: _controller.isEditMode.value
                    ? ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
                        itemCount: _controller.device.value.channels.length,
                        separatorBuilder: (_, __) => 12.asSpace,
                        itemBuilder: (_, index) {
                          final current = _controller.device.value.channels[index];

                          return Watch(
                            (_) => TextFormField(
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                labelText: current.id,
                              ),
                              initialValue: current.name,
                              onChanged: (v) => _controller.onChangeChannelName(current.id, v),
                              style: context.textTheme.titleSmall,
                            ),
                          );
                        },
                      )
                    : SelectableListView(
                        options: _controller.device.value.channels,
                        onSelect: (c) => widget.onSelect(
                          c,
                          _controller.zone.value,
                          _controller.device.value.channels,
                        ),
                        selectedOption: _controller.zone.value.channel,
                        onTapEdit: _controller.toggleEditMode,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
