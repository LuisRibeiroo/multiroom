import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:routefly/routefly.dart';
import 'package:signals/signals.dart';
import 'package:toastification/toastification.dart';
import 'package:window_manager/window_manager.dart';

import 'app/core/interactor/repositories/hive_settings.dart';
import 'app/core/interactor/repositories/settings_contract.dart';
import 'app/core/interactor/utils/hive_utils.dart';
import 'app/core/theme/theme.dart';
import 'app/core/utils/platform_checker.dart';
import 'injector.dart';
import 'routes.g.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SignalsObserver.instance = null;
  // SignalsObserver.instance = LoggingSignalsObserver();

  if (PlatformChecker.isMobile == false) {
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

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  SystemChannels.textInput.invokeMethod('TextInput.hide');

  final hiveBox = await HiveUtils.init();
  injector.addLazySingleton<SettingsContract>(() => HiveSettings(box: hiveBox));

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
