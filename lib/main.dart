import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:routefly/routefly.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

import 'app/core/interactor/repositories/settings_contract.dart';
import 'app/core/interactor/repositories/shared_prefs_settings.dart';
import 'app/core/theme/theme.dart';
import 'injector.dart';
import 'routes.g.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  EquatableConfig.stringify = true;

  // Lock the orientation to landscape
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  SystemChannels.textInput.invokeMethod('TextInput.hide');

  final sharedPrefs = await SharedPreferences.getInstance();

  injector.addLazySingleton<SettingsContract>(() => SharedPrefsSettings(prefs: sharedPrefs));
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
        initialPath: routePaths.startup.pages.startup,
      ),
    );
  }
}
