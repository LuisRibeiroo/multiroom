import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:multiroom/app/core/widgets/loading_overlay.dart';
import 'package:routefly/routefly.dart';
import 'package:signals/signals_flutter.dart';

import '../../../../../injector.dart';
import '../../../../core/extensions/build_context_extensions.dart';
import '../../../../core/extensions/number_extensions.dart';
import '../../../../core/extensions/string_extensions.dart';
import '../../../../core/models/zone_model.dart';
import '../../../../core/models/zone_wrapper_model.dart';
import '../../../scanner/ui/widgets/device_master_indicator.dart';
import '../../interactor/controllers/device_configuration_page_controller.dart';

class DeviceConfigurationPage extends StatefulWidget {
  const DeviceConfigurationPage({super.key});

  @override
  State<DeviceConfigurationPage> createState() => _DeviceConfigurationPageState();
}

class _DeviceConfigurationPageState extends State<DeviceConfigurationPage> {
  final _controller = injector.get<DeviceConfigurationPageController>();

  final nameFocusNode = FocusNode();
  final _zonesExpandableController = ExpandableController(initialExpanded: false);
  // final _groupsExpandableController = ExpandableController(initialExpanded: false);

  @override
  void initState() {
    super.initState();

    _controller.init(device: Routefly.query.arguments);
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
                              Visibility(
                                child: DeviceMasterIndicator(
                                  type: _controller.device.value.type,
                                  label: _controller.device.value.masterName.or("M1"),
                                ),
                              ),
                              12.asSpace,
                              Text(
                                _controller.device.value.ip,
                                style: context.textTheme.titleMedium,
                              ),
                              12.asSpace,
                            ],
                          ),
                          8.asSpace,
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
                  12.asSpace,
                  Card.filled(
                    clipBehavior: Clip.hardEdge,
                    child: ExpandablePanel(
                      controller: _zonesExpandableController,
                      theme: ExpandableThemeData(
                        iconColor: context.colorScheme.onSurface,
                        iconPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 18.0),
                      ),
                      header: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 18.0),
                        child: Text(
                          "Zonas",
                          style: context.textTheme.titleLarge,
                        ),
                      ),
                      collapsed: const SizedBox.shrink(),
                      expanded: Padding(
                        padding: const EdgeInsets.only(bottom: 12.0, left: 12, right: 12),
                        child: Column(
                          children: [
                            const Divider(),
                            ...List.generate(
                              _controller.device.value.zones.length,
                              (idx) {
                                final wrapper = _controller.device.value.zones[idx];

                                return Watch(
                                  (_) => Column(
                                    children: [
                                      SwitchListTile(
                                        title: Text("Zona ${idx + 1}"),
                                        subtitle: Text(wrapper.mode.name.capitalize),
                                        value: wrapper.isStereo,
                                        onChanged: (value) => _controller.onChangeZoneMode(wrapper, value),
                                      ),
                                      AnimatedSize(
                                        duration: Durations.medium2,
                                        child: Column(
                                          key: ValueKey(wrapper.isStereo),
                                          children: [
                                            Visibility(
                                              visible: wrapper.isStereo,
                                              child: ZoneNameEditTile(
                                                zone: wrapper.stereoZone,
                                                wrapper: wrapper,
                                                isEditing: _controller.editingWrapper.value.id == wrapper.id &&
                                                    _controller.isEditingZone.value,
                                                onChangeZoneName: _controller.onChangeZoneName,
                                                toggleEditing: _controller.toggleEditingZone,
                                              ),
                                            ),
                                            Visibility(
                                              visible: wrapper.isStereo == false,
                                              child: ZoneNameEditTile(
                                                zone: wrapper.monoZones.right,
                                                wrapper: wrapper,
                                                isEditing:
                                                    _controller.editingZone.value.id == wrapper.monoZones.right.id &&
                                                        _controller.isEditingZone.value,
                                                onChangeZoneName: _controller.onChangeZoneName,
                                                toggleEditing: _controller.toggleEditingZone,
                                              ),
                                            ),
                                            8.asSpace,
                                            Visibility(
                                              visible: wrapper.isStereo == false,
                                              child: ZoneNameEditTile(
                                                zone: wrapper.monoZones.left,
                                                wrapper: wrapper,
                                                isEditing:
                                                    _controller.editingZone.value.id == wrapper.monoZones.left.id &&
                                                        _controller.isEditingZone.value,
                                                onChangeZoneName: _controller.onChangeZoneName,
                                                toggleEditing: _controller.toggleEditingZone,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
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
    super.dispose();

    _controller.dispose();
  }
}

class ZoneNameEditTile extends StatelessWidget {
  const ZoneNameEditTile({
    super.key,
    required this.wrapper,
    required this.zone,
    required this.isEditing,
    required this.onChangeZoneName,
    required this.toggleEditing,
  });

  final ZoneWrapperModel wrapper;
  final ZoneModel zone;
  final bool isEditing;
  final Function(ZoneModel, String) onChangeZoneName;
  final Function(ZoneWrapperModel, ZoneModel) toggleEditing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            enabled: isEditing,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            initialValue: zone.name,
            onChanged: (value) => onChangeZoneName(zone, value),
            style: context.textTheme.titleSmall,
          ),
        ),
        12.asSpace,
        IconButton(
          onPressed: () => toggleEditing(wrapper, zone),
          icon: AnimatedSwitcher(
            duration: Durations.short3,
            child: Icon(
              key: ValueKey(isEditing),
              isEditing ? Icons.check_rounded : Icons.edit_rounded,
            ),
          ),
        ),
      ],
    );
  }
}
