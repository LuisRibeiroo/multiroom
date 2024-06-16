import 'dart:async';

import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../../../../injector.dart';
import '../../../core/extensions/number_extensions.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../../widgets/device_controls.dart';
import '../../widgets/device_info_header.dart';
import '../interactor/home_page_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = injector.get<HomePageController>();

  @override
  void initState() {
    super.initState();

    scheduleMicrotask(() async {});
  }

  @override
  Widget build(BuildContext context) {
    return Watch(
      (_) => LoadingOverlay(
        state: _controller.state,
        child: Scaffold(
          appBar: AppBar(
            leading: Image.asset("assets/logo.png"),
            title: const Text('Multiroom'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            scrolledUnderElevation: 0,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: Durations.medium1,
                    child: _controller.device.value.isEmpty
                        ? const SizedBox.shrink()
                        : DeviceInfoHeader(
                            device: _controller.device.value,
                            currentZone: _controller.currentZone.value,
                            currentChannel: _controller.currentChannel.value,
                            onChangeZone: _controller.setCurrentZone,
                            onChangeChannel: _controller.setCurrentChannel,
                            channelController: _controller.channelController,
                          ),
                  ),
                  12.asSpace,
                  AnimatedSwitcher(
                    duration: Durations.medium1,
                    child: _controller.device.value.isEmpty
                        ? const SizedBox.shrink()
                        : DeviceControls(
                            currentZone: _controller.currentZone.value,
                            currentEqualizer: _controller.currentEqualizer.value,
                            equalizers: _controller.equalizers.value,
                            onChangeBalance: _controller.setBalance,
                            onChangeVolume: _controller.setVolume,
                            onChangeEqualizer: _controller.setEqualizer,
                            onUpdateFrequency: _controller.setFrequency,
                            equalizerController: _controller.equalizerController,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
