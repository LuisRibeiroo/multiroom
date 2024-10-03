import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:routefly/routefly.dart';

import '../../../../injector.dart';
import '../../../../routes.g.dart';
import '../../../core/extensions/number_extensions.dart';
import '../../../core/interactor/controllers/device_monitor_controller.dart';
import '../../../core/interactor/repositories/settings_contract.dart';
import '../../../core/utils/platform_checker.dart';

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
      if (PlatformChecker.isMobile) {
        await [
          Permission.location,
          Permission.nearbyWifiDevices,
          Permission.locationWhenInUse,
        ].request();
      }

      final settings = injector.get<SettingsContract>();

      final monitorController = injector.get<DeviceMonitorController>();

      await monitorController.scanDevices(
        updateIp: true,
        awaitFinish: true,
      );

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
