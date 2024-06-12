import 'package:flutter/material.dart';

import '../../../../../injector.dart';
import '../../interactor/controllers/device_configuration_page_controller.dart';

class DeviceConfigurationPage extends StatefulWidget {
  const DeviceConfigurationPage({super.key});

  @override
  State<DeviceConfigurationPage> createState() => _DeviceConfigurationPageState();
}

class _DeviceConfigurationPageState extends State<DeviceConfigurationPage> {
  @override
  Widget build(BuildContext context) {
    final _controller = injector.get<DeviceConfigurationPageController>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configuração do dispositivo"),
      ),
      body: const Column(
        children: [],
      ),
    );
  }
}
