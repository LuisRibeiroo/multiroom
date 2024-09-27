import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:multiroom/app/core/interactor/controllers/device_monitor_controller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:routefly/routefly.dart';

import '../../../../injector.dart';
import '../../../../routes.g.dart';
import '../../../core/extensions/number_extensions.dart';
import '../../../core/interactor/repositories/settings_contract.dart';

class StartupPage extends StatefulWidget {
  const StartupPage({super.key});

  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  @override
  void initState() {
    super.initState();

    scheduleMicrotask(() async {
      if (Platform.isAndroid || Platform.isIOS) {
        await [
          Permission.location,
          Permission.nearbyWifiDevices,
          Permission.locationWhenInUse,
        ].request();
      }

      final settings = injector.get<SettingsContract>();

      settings.saveDevice(device: settings.devices.first.copyWith(ip: "192.1.1.1"));

      final monitorController = injector.get<DeviceMonitorController>();

      await monitorController.scanDevices(
        updateIp: true,
        awaitFinish: true,
      );

      // final testZones = List.generate(
      //   8,
      //   (idx) => ZoneWrapperModel.builder(
      //     index: idx + 1,
      //     name: "Zona ${idx + 1}",
      //     mode: idx.isEven ? ZoneMode.stereo : ZoneMode.mono,
      //   ),
      // );

      // settings.saveDevices([
      //   DeviceModel.builder(
      //     serialNumber: "MR01234-0931",
      //     name: "Master 1",
      //     ip: "192.168.0.1",
      //     version: "3.2",
      //     type: DeviceType.master,
      //   ),
      //   DeviceModel(
      //     serialNumber: "MR01234-0932",
      //     name: "Slave 1",
      //     ip: "192.168.0.2",
      //     version: "3.2",
      //     type: DeviceType.slave,
      //     masterName: "Master 1",
      //     zoneWrappers: testZones,
      //     groups: List.generate(
      //       3,
      //       (idx) => ZoneGroupModel(
      //         id: "G${idx + 1}",
      //         name: "Grupo ${idx + 1}",
      //         zones: idx.isEven ? testZones[idx].zones : [],
      //       ),
      //     ),
      //   ),
      //   DeviceModel.builder(
      //     serialNumber: "MR01234-0933",
      //     name: "Slave 2",
      //     ip: "192.168.0.3",
      //     version: "3.2",
      //     type: DeviceType.slave,
      //   ),
      // ]);

      // settings.saveDevices([]);

      if (settings.projects.isEmpty) {
        Routefly.replace(routePaths.modules.configs.pages.configs);
        Routefly.pushNavigate(routePaths.modules.configs.pages.configs);
      } else {
        Routefly.replace(routePaths.modules.home.pages.home);
        Routefly.pushNavigate(routePaths.modules.home.pages.home);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Image.asset("assets/logo_completo.png"),
            24.asSpace,
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
