import 'dart:async';

import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../../../../../injector.dart';
import '../../../../core/extensions/build_context_extensions.dart';
import '../../../../core/extensions/number_extensions.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../interactor/controllers/scanner_page_controller.dart';
import '../widgets/device_list_tile.dart';

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
                    itemBuilder: (_, index) => Watch(
                      (_) => DeviceListTile(
                        device: _controller.devicesList[index],
                        onChangeActive: _controller.onChangeActive,
                        onChangeType: _controller.onChangeType,
                      ),
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
