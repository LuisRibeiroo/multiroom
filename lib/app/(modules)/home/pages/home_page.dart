import 'dart:async';

import 'package:flutter/material.dart';
import 'package:routefly/routefly.dart';
import 'package:signals/signals_flutter.dart';

import '../../../../injector.dart';
import '../../../core/extensions/build_context_extensions.dart';
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

  void _showZonesBottomSheet() {
    context.showCustomModalBottomSheet(
      isScrollControlled: false,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 12.0),
        itemCount: _controller.zones.length,
        itemBuilder: (_, index) {
          final current = _controller.zones[index];

          return ListTile(
            title: Text(current.name),
            onTap: () {
              _controller.setCurrentZone(current);
              Routefly.pop(context);
            },
          );
        },
      ),
    );
  }

  void _showChannelsBottomSheet() {
    context.showCustomModalBottomSheet(
      isScrollControlled: false,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 12.0),
        itemCount: _controller.channels.length,
        itemBuilder: (_, index) {
          final current = _controller.channels[index];

          return ListTile(
            title: Text(current.name),
            onTap: () {
              _controller.setCurrentChannel(current);
              Routefly.pop(context);
            },
          );
        },
      ),
    );
  }

  void _showEqualizersBottomSheet() {
    context.showCustomModalBottomSheet(
      isScrollControlled: false,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 12.0),
        itemCount: _controller.equalizers.length,
        itemBuilder: (_, index) {
          final current = _controller.equalizers[index];

          return ListTile(
            title: Text(current.name),
            onTap: () {
              _controller.setEqualizer(current.name);
              Routefly.pop(context);
            },
          );
        },
      ),
    );
  }

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
          body: SafeArea(
            child: SingleChildScrollView(
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
                              deviceName: _controller.device.value.name,
                              zones: _controller.zones,
                              currentZone: _controller.currentZone.value,
                              currentChannel: _controller.currentChannel.value,
                              onChangeChannel: _showChannelsBottomSheet,
                              onChangeZone: _showZonesBottomSheet,
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
                              onUpdateFrequency: _controller.setFrequency,
                              onChangeEqualizer: _showEqualizersBottomSheet,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
