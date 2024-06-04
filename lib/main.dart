import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:multiroom/injector.dart';
import 'package:routefly/routefly.dart';
import 'package:toastification/toastification.dart';

import 'app/core/theme.dart';
import 'routes.dart';

void main() {
  EquatableConfig.stringify = true;

  injector.commit();

  runApp(const ToastificationWrapper(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Multiroom',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: MaterialTheme.lightHighContrastScheme().toColorScheme(),
      ),
      darkTheme: ThemeData(
        colorScheme: MaterialTheme.darkHighContrastScheme().toColorScheme(),
      ),
      themeMode: ThemeMode.dark,
      routerConfig: Routefly.routerConfig(
        routes: routes,
        initialPath: routePaths.devices.ui.pages.home,
      ),
    );
  }
}
