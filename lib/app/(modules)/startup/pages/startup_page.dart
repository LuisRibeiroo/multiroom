import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:routefly/routefly.dart';

import '../../../../injector.dart';
import '../../../../routes.g.dart';
import '../../../core/enums/device_type.dart';
import '../../../core/enums/zone_mode.dart';
import '../../../core/extensions/number_extensions.dart';
import '../../../core/interactor/repositories/settings_contract.dart';
import '../../../core/models/device_model.dart';
import '../../../core/models/zone_wrapper_model.dart';

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
      //     zoneWrappers: List.generate(
      //       8,
      //       (idx) => ZoneWrapperModel.builder(
      //         index: idx + 1,
      //         name: "Zona ${idx + 1}",
      //         mode: idx.isEven ? ZoneMode.stereo : ZoneMode.mono,
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

      await Future.delayed(const Duration(seconds: 1), () {
        if (settings.devices.isEmpty) {
          Routefly.replace(routePaths.configs.pages.configs);
          Routefly.pushNavigate(routePaths.configs.pages.configs);
        } else {
          Routefly.replace(routePaths.home.pages.home);
          Routefly.pushNavigate(routePaths.home.pages.home);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Image.asset("assets/logo_completo.png"),
          24.asSpace,
          const CircularProgressIndicator(),
        ],
      ),
    );
  }
}
