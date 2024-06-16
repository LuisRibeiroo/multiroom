import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:signals/signals_flutter.dart';

import '../../../injector.dart';
import '../../core/extensions/number_extensions.dart';
import '../../core/extensions/text_input_formatter_extensions.dart';
import '../../core/widgets/loading_overlay.dart';
import '../widgets/device_controls.dart';
import '../widgets/device_info_header.dart';
import 'demo_page_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = injector.get<HomePageController>();

  late final TextEditingController _hostEditingController;
  late final TextEditingController _portEditingController;

  @override
  void initState() {
    super.initState();

    _hostEditingController = TextEditingController(text: _controller.host.peek());
    _portEditingController = TextEditingController(text: _controller.port.peek());

    effect(() {
      _hostEditingController.text = _controller.host.value;
      _portEditingController.text = _controller.port.value;
    });

    scheduleMicrotask(() async {
      if (Platform.isAndroid || Platform.isIOS) {
        await [
          Permission.location,
          Permission.nearbyWifiDevices,
          Permission.locationWhenInUse,
        ].request();
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
                  Card.filled(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 18,
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                flex: 2,
                                child: TextFormField(
                                  enabled: _controller.isConnected.value == false,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'IP do Host',
                                  ),
                                  onChanged: _controller.host.set,
                                  controller: _hostEditingController,
                                  inputFormatters: TextInputFormatterExt.ip(),
                                ),
                              ),
                              8.asSpace,
                              Flexible(
                                child: TextFormField(
                                  enabled: _controller.isConnected.value == false,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Porta',
                                  ),
                                  onChanged: _controller.port.set,
                                  controller: _portEditingController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [LengthLimitingTextInputFormatter(4)],
                                ),
                              )
                            ],
                          ),
                          12.asSpace,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Flexible(
                                child: Watch(
                                  (_) => AnimatedSwitcher(
                                    duration: Durations.medium1,
                                    child: ElevatedButton(
                                      key: ValueKey(_controller.isServerListening.value),
                                      onPressed: _controller.isConnected.value ? null : _controller.toggleUdpServer,
                                      child: Text(
                                        _controller.isServerListening.value ? "Parar" : "Iniciar escuta",
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Watch(
                                  (_) => AnimatedSwitcher(
                                    duration: Durations.medium1,
                                    child: ElevatedButton(
                                      key: ValueKey(_controller.isConnected.value),
                                      onPressed: _controller.toggleConnection,
                                      child: Text(
                                        _controller.isConnected.value ? "Desconectar" : "Conectar",
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            key: ValueKey(_controller.isConnected.value),
                            onPressed: _controller.test,
                            child: const Text("Teste"),
                          )
                        ],
                      ),
                    ),
                  ),
                  24.asSpace,
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
