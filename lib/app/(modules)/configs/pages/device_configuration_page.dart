import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import '../widgets/delete_device_confirm_bottom_sheet.dart';
import '../../../core/enums/device_type.dart';
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
                  Card.outlined(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              DeviceTypeIndicator(
                                active: _controller.device.value.type == DeviceType.master,
                                label: _controller.device.value.type.name.capitalize,
                              ),
                              12.asSpace,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _controller.device.value.ip,
                                    style: context.textTheme.titleMedium,
                                  ),
                                  4.asSpace,
                                  Text(
                                    _controller.device.value.serialNumber,
                                  ),
                                  Text(
                                    "Ver ${_controller.device.value.version}",
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
                    isEditing: _controller.isEditingGroup.value,
                    groups: _controller.device.value.groups,
                    expandableController: _groupsExpandableController,
                    editingGroup: _controller.editingGroup.value,
                    onTapAddGroup: _showAddZoneGroupBottomSheet,
                    onTapRemoveZone: _controller.onRemoveZoneFromGroup,
                    toggleEditingGroup: _controller.toggleEditingGroup,
                    onChangeGroupName: _controller.onChangeGroupName,
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
