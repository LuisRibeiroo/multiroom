import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:routefly/routefly.dart';
import 'package:signals/signals_flutter.dart';

import '../../../../injector.dart';
import '../../../core/extensions/build_context_extensions.dart';
import '../../../core/extensions/number_extensions.dart';
import '../../../core/extensions/string_extensions.dart';
import '../../../core/models/zone_group_model.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../../scanner/widgets/device_type_indicator.dart';
import '../controllers/device_configuration_page_controller.dart';
import '../widgets/groups_expandable_card.dart';
import '../widgets/zones_expandable_card.dart';

class DeviceConfigurationPage extends StatefulWidget {
  const DeviceConfigurationPage({super.key});

  @override
  State<DeviceConfigurationPage> createState() => _DeviceConfigurationPageState();
}

class _DeviceConfigurationPageState extends State<DeviceConfigurationPage> {
  final _controller = injector.get<DeviceConfigurationPageController>();

  final _zonesExpandableController = ExpandableController(initialExpanded: false);
  final _groupsExpandableController = ExpandableController(initialExpanded: false);

  void _showDeviceDeletionBottomSheet() {
    context.showCustomModalBottomSheet(
      isScrollControlled: false,
      child: DeleteDeviceConfirmBottomSheet(
        deviceName: _controller.device.value.name,
        onConfirm: _controller.removeDevice,
      ),
    );
  }

  void _showAddZoneGroupBottomSheet(ZoneGroupModel group) {
    context.showCustomModalBottomSheet(
      isScrollControlled: false,
      child: Watch(
        (_) => ListView.builder(
          shrinkWrap: true,
          itemCount: _controller.availableZones.value.length,
          itemBuilder: (_, index) {
            final zone = _controller.availableZones.value[index];

            return ListTile(
              title: Text(zone.label),
              trailing: const Icon(Icons.add_circle_rounded),
              onTap: () {
                _controller.onAddZoneToGroup(group, zone);
                Routefly.pop(context);
              },
            );
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _controller.init(dev: Routefly.query.arguments);
  }

  @override
  Widget build(BuildContext context) {
    return Watch(
      (_) => LoadingOverlay(
        state: _controller.state,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Configuração do dispositivo"),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Card.filled(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              DeviceTypeIndicator(
                                active: true,
                                label: _controller.device.value.masterName.or("M"),
                              ),
                              12.asSpace,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _controller.device.value.ip,
                                    style: context.textTheme.bodyLarge,
                                  ),
                                  4.asSpace,
                                  Text(
                                    _controller.device.value.serialNumber,
                                    style: context.textTheme.bodyMedium,
                                  ),
                                  Text(
                                    "V ${_controller.device.value.version}",
                                    style: context.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                              12.asSpace,
                              const Spacer(),
                              IconButton.outlined(
                                onPressed: _showDeviceDeletionBottomSheet,
                                icon: const Icon(Icons.delete_rounded),
                              ),
                            ],
                          ),
                          const Divider(height: 32),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  enabled: _controller.isEditingDevice.value,
                                  onChanged: _controller.deviceName.set,
                                  initialValue: _controller.deviceName.value,
                                  style: context.textTheme.titleMedium,
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              12.asSpace,
                              IconButton(
                                onPressed: _controller.toggleEditingDevice,
                                icon: AnimatedSwitcher(
                                  duration: Durations.short3,
                                  child: Icon(
                                    key: ValueKey(_controller.isEditingDevice.value),
                                    _controller.isEditingDevice.value ? Icons.check_rounded : Icons.edit_rounded,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  8.asSpace,
                  ZonesExpandableCard(
                    expandableController: _zonesExpandableController,
                    zones: _controller.device.value.zoneWrappers,
                    editingWrapper: _controller.editingWrapper.value,
                    editingZone: _controller.editingZone.value,
                    isEditing: _controller.isEditingZone.value,
                    onChangeZoneMode: _controller.onChangeZoneMode,
                    onChangeZoneName: _controller.onChangeZoneName,
                    toggleEditingZone: _controller.toggleEditingZone,
                  ),
                  8.asSpace,
                  GroupsExpandableCard(
                    groups: _controller.device.value.groups,
                    expandableController: _groupsExpandableController,
                    onTapAddGroup: _showAddZoneGroupBottomSheet,
                    onTapRemoveZone: _controller.onRemoveZoneFromGroup,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _zonesExpandableController.dispose();
    _controller.dispose();

    super.dispose();
  }
}

class DeleteDeviceConfirmBottomSheet extends StatelessWidget {
  const DeleteDeviceConfirmBottomSheet({
    super.key,
    required this.deviceName,
    required this.onConfirm,
  });

  final String deviceName;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Tem certeza que deseja remover o dispositivo \"$deviceName\"?",
            style: context.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          24.asSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton(
                child: const Text("Cancelar"),
                onPressed: () {
                  Routefly.pop(context);
                },
              ),
              ElevatedButton(
                child: const Text("Sim"),
                onPressed: () {
                  onConfirm();

                  Routefly.pop(context);
                  Routefly.pop(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
