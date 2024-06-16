import 'dart:async';

import 'package:flutter/material.dart';
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
      final settings = injector.get<SettingsContract>();

      await Future.delayed(const Duration(seconds: 1), () {
        if (settings.devices.isEmpty) {
          // if (settings.devices.isEmpty) {
          Routefly.replace(routePaths.configs.pages.configs);
          Routefly.pushNavigate(routePaths.configs.pages.configs);
        } else {
          Routefly.replace(routePaths.home.pages.deviceDemo);
          Routefly.pushNavigate(routePaths.home.pages.deviceDemo);
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
