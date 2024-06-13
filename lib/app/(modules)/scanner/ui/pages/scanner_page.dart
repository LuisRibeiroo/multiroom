import 'dart:async';

import 'package:flutter/material.dart';
import 'package:routefly/routefly.dart';
import 'package:signals/signals_flutter.dart';

import '../../../../../injector.dart';
import '../../../../core/extensions/build_context_extensions.dart';
import '../../../../core/extensions/number_extensions.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../interactor/controllers/scanner_page_controller.dart';
import '../../interactor/models/network_device_model.dart';
import '../widgets/device_list_tile.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final _controller = injector.get<ScannerPageController>();

  void _showNetworkDevicesBottomSheet() {
    context.showCustomModalBottomSheet(
      isScrollControlled: false,
      child: Watch(
        (_) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Dispositivos encontrados na rede",
              style: context.textTheme.titleLarge,
            ),
            12.asSpace,
            Flexible(
              child: AnimatedSwitcher(
                duration: Durations.short4,
                child: _controller.networkDevices.isEmpty
                    ? const CircularProgressIndicator()
                    : ListView.builder(
                        itemCount: _controller.networkDevices.length,
                        itemBuilder: (_, index) {
                          final netDevice = _controller.networkDevices[index];

                          return ListTile(
                            title: Text(netDevice.ip),
                            subtitle: Text(
                              "${netDevice.serialNumber} - Ver ${netDevice.firmware}",
                            ),
                            trailing: const Icon(Icons.add_circle_rounded),
                            onTap: () {
                              Routefly.pop(context);

                              context.showCustomModalBottomSheet(
                                child: Watch(
                                  (_) => Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Modo",
                                        style: context.textTheme.titleLarge,
                                      ),
                                      12.asSpace,
                                      Wrap(
                                        spacing: 24,
                                        alignment: WrapAlignment.center,
                                        runAlignment: WrapAlignment.center,
                                        children: [
                                          ChoiceChip(
                                            label: const Text("Master"),
                                            selected: _controller.deviceType.value == NetworkDeviceType.master,
                                            onSelected: (_) => _controller.deviceType.set(NetworkDeviceType.master),
                                          ),
                                          ChoiceChip(
                                            label: const Text("Slave 1"),
                                            selected: _controller.deviceType.value == NetworkDeviceType.slave1,
                                            onSelected: (_) => _controller.deviceType.set(NetworkDeviceType.slave1),
                                          ),
                                          ChoiceChip(
                                            label: const Text("Slave 2"),
                                            selected: _controller.deviceType.value == NetworkDeviceType.slave2,
                                            onSelected: (_) => _controller.deviceType.set(NetworkDeviceType.slave2),
                                          ),
                                        ],
                                      ),
                                      24.asSpace,
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.add_rounded),
                                        label: const Text("Adicionar"),
                                        onPressed: () {
                                          Routefly.pop(context);
                                          _controller.onConfirmAddDevice(netDevice);
                                        },
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    scheduleMicrotask(() async {
      if (_controller.localDevices.isEmpty) {
        await _controller.init();
        _showNetworkDevicesBottomSheet();
      }
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
            child: _controller.localDevices.isEmpty
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
                    itemCount: _controller.localDevices.length,
                    itemBuilder: (_, index) => Watch(
                      (_) => DeviceListTile(
                        device: _controller.localDevices[index],
                        onChangeActive: _controller.onChangeActive,
                        onChangeType: _controller.onChangeType,
                      ),
                    ),
                  ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showNetworkDevicesBottomSheet,
            child: const Icon(Icons.settings_input_antenna_rounded),
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
