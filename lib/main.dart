import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:restart_app/restart_app.dart';
import 'package:routefly/routefly.dart';
import 'package:toastification/toastification.dart';
import 'package:window_manager/window_manager.dart';

import 'app/core/interactor/repositories/hive_settings.dart';
import 'app/core/interactor/repositories/settings_contract.dart';
import 'app/core/interactor/utils/hive_utils.dart';
import 'app/core/theme/theme.dart';
import 'injector.dart';
import 'routes.g.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid == false && Platform.isIOS == false) {
    await windowManager.ensureInitialized();

    const size = Size(650, 730);
    WindowOptions windowOptions = const WindowOptions(
      size: size,
      maximumSize: size,
      minimumSize: size,
      backgroundColor: Colors.transparent,
      windowButtonVisibility: false,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setMaximizable(false);
      await windowManager.setResizable(false);

      await windowManager.show();
      await windowManager.focus();
    });
  }

  EquatableConfig.stringify = true;

  // Lock the orientation to landscape
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  SystemChannels.textInput.invokeMethod('TextInput.hide');

  final hiveBox = await HiveUtils.init();
  injector.addLazySingleton<SettingsContract>(() => HiveSettings(box: hiveBox));

  injector.commit();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);

    _restartAppDialog();
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    _restartAppDialog();

    return true;
  };

  runApp(const ToastificationWrapper(child: MyApp()));
}

void _restartAppDialog() {
  Restart.restartApp();
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
        appBarTheme: AppBarTheme(
          backgroundColor: MaterialTheme.darkHighContrastScheme().inversePrimary,
          scrolledUnderElevation: 0,
        ),
      ),
      themeMode: ThemeMode.dark,
      routerConfig: Routefly.routerConfig(
        routes: routes,
        initialPath: routePaths.modules.startup.pages.startup,
      ),
    );
  }
}
