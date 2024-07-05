import 'package:flutter/material.dart';
import 'package:routefly/routefly.dart';
import 'package:signals/signals_flutter.dart';

import '../../../../injector.dart';
import '../../../core/extensions/number_extensions.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../../shared/widgets/text_edit_tile.dart';
import '../interactor/edit_channels_page_controller.dart';

class EditChannelsPage extends StatefulWidget {
  const EditChannelsPage({super.key});

  @override
  State<EditChannelsPage> createState() => _EditChannelsPageState();
}

class _EditChannelsPageState extends State<EditChannelsPage> {
  final _controller = injector.get<EditChannelsPageController>();
  @override
  void initState() {
    super.initState();

    final args = Routefly.query.arguments;

    _controller.init(
      device: args["device"],
      zone: args["zone"],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Watch(
      (_) => LoadingOverlay(
        state: _controller.state,
        child: Scaffold(
          appBar: AppBar(
            title: Text("${_controller.zone.value.name} - Canais"),
          ),
          body: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
            itemCount: _controller.zone.value.channels.length,
            separatorBuilder: (_, __) => 12.asSpace,
            itemBuilder: (_, index) {
              final current = _controller.zone.value.channels[index];

              return Watch(
                (_) => TextEditTile(
                  itemId: current.id,
                  initialValue: current.name,
                  isEditing: _controller.isEditing.value && _controller.editingChannelId.value == current.id,
                  onChangeValue: _controller.onChangeChannelName,
                  toggleEditing: _controller.toggleEditing,
                  hideEditButton: _controller.isEditing.value && _controller.editingChannelId.value != current.id,
                ),
              );
            },
          ),
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
