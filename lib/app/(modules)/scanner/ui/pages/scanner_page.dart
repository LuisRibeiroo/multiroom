import 'dart:async';

import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../../../../../injector.dart';
import '../../../../core/extensions/build_context_extensions.dart';
import '../../../../core/extensions/number_extensions.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../interactor/controllers/scanner_page_controller.dart';
import '../widgets/device_master_indicator.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final _controller = injector.get<ScannerPageController>();

  @override
  void initState() {
    super.initState();
    scheduleMicrotask(() async {
      _controller.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Watch(
      (_) => LoadingOverlay(
        state: _controller.state,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Dispositivos"),
            actions: [
              Visibility(
                visible: _controller.isUdpListening.value,
                child: const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(),
                ),
              ),
              24.asSpace,
            ],
          ),
          body: AnimatedSwitcher(
            duration: Durations.short4,
            child: _controller.devicesList.isEmpty
                ? Center(
                    key: const ValueKey("empty"),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),
                        const Icon(
                          Icons.settings_input_antenna_rounded,
                          size: 80,
                        ),
                        Text(
                          'Procurando dispositivos',
                          style: context.textTheme.titleLarge,
                        ),
                        12.asSpace,
                        const CircularProgressIndicator(),
                        const Spacer(),
                        40.asSpace,
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _controller.devicesList.length,
                    itemBuilder: (_, index) {
                      final device = _controller.devicesList[index];

                      return Watch(
                        (_) => Card.filled(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: Row(
                              children: [
                                Checkbox.adaptive(
                                  value: device.active,
                                  onChanged: (value) => _controller.onChangeActive(device, value!),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        device.ip,
                                        style: context.textTheme.titleMedium,
                                      ),
                                      Text(
                                        "Ver ${device.version}",
                                        style: context.textTheme.labelMedium,
                                      ),
                                    ],
                                  ),
                                ),
                                12.asSpace,
                                Column(
                                  children: [
                                    RadioMenuButton(
                                      value: "master",
                                      groupValue: device.type.name,
                                      onChanged: (value) => _controller.onChangeType(device, value!),
                                      child: const Text("Master"),
                                    ),
                                    RadioMenuButton(
                                      value: "slave1",
                                      groupValue: device.type.name,
                                      onChanged: (value) => _controller.onChangeType(device, value!),
                                      child: const Text("Slave1"),
                                    ),
                                    RadioMenuButton(
                                      value: "slave2",
                                      groupValue: device.type.name,
                                      onChanged: (value) => _controller.onChangeType(device, value!),
                                      child: const Text("Slave2"),
                                    ),
                                  ],
                                ),
                                12.asSpace,
                                Column(
                                  children: [
                                    DeviceMasterIndicator(
                                      label: "M1",
                                      type: device.type,
                                    ),
                                    DeviceMasterIndicator(
                                      label: "M2",
                                      type: device.type,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
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
