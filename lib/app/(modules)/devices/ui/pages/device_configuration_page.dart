import 'package:flutter/material.dart';
import 'package:routefly/routefly.dart';
import 'package:signals/signals_flutter.dart';

import '../../../../../injector.dart';
import '../../../../core/extensions/build_context_extensions.dart';
import '../../../../core/extensions/number_extensions.dart';
import '../../../../core/extensions/string_extensions.dart';
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

  @override
  void initState() {
    super.initState();

    _controller.init(device: Routefly.query.arguments);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configuração do dispositivo"),
      ),
      body: Watch(
        (_) => Padding(
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
                              enabled: _controller.isEditing.value,
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
                            onPressed: _controller.toggleEditing,
                            icon: AnimatedSwitcher(
                              duration: Durations.short3,
                              child: Icon(
                                key: ValueKey(_controller.isEditing.value),
                                _controller.isEditing.value ? Icons.check_rounded : Icons.edit_rounded,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
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
