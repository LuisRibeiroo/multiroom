import 'package:flutter/material.dart';
import 'package:routefly/routefly.dart';
import 'package:signals/signals_flutter.dart';

import '../../../../injector.dart';
import '../../../core/extensions/number_extensions.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../../shared/widgets/text_edit_tile.dart';
import '../../widgets/icon_title.dart';
import '../interactor/edit_zones_page_controller.dart';

class EditZonesPage extends StatefulWidget {
  const EditZonesPage({super.key});

  @override
  State<EditZonesPage> createState() => _EditZonesPageState();
}

class _EditZonesPageState extends State<EditZonesPage> {
  final _controller = injector.get<EditZonesPageController>();

  @override
  void initState() {
    super.initState();

    final args = Routefly.query.arguments;

    _controller.init(
      project: args["project"],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Watch(
      (_) => LoadingOverlay(
        state: _controller.state,
        child: Scaffold(
          appBar: AppBar(
            title: Text(_controller.project.value.name),
          ),
          body: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
            itemCount: _controller.project.value.devices.length,
            separatorBuilder: (_, __) => 18.asSpace,
            itemBuilder: (_, index) {
              final device = _controller.project.value.devices[index];

              return Card.outlined(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconTitle(
                        title: device.name,
                        icon: Icons.surround_sound_rounded,
                        // style: context.textTheme.titleMedium,
                      ),
                      24.asSpace,
                      ListView.separated(
                        shrinkWrap: true,
                        itemCount: device.groupedZones.length,
                        separatorBuilder: (_, __) => 12.asSpace,
                        itemBuilder: (_, idx) {
                          final zone = device.groupedZones[idx];

                          return Watch(
                            (_) => TextEditTile(
                              itemId: zone.id,
                              initialValue: zone.name,
                              isEditing: _controller.isEditing.value &&
                                  _controller.editingZoneId.value == zone.id &&
                                  _controller.editingDeviceSerial.value == device.serialNumber,
                              onChangeValue: _controller.onChangeZoneName,
                              toggleEditing: (_) => _controller.toggleEditing(device, zone),
                              hideEditButton: _controller.isEditing.value &&
                                  (_controller.editingZoneId.value != zone.id ||
                                      _controller.editingDeviceSerial.value != device.serialNumber),
                            ),
                          );
                        },
                      )
                    ],
                  ),
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
