import 'package:shared_preferences/shared_preferences.dart';

import 'settings_contract.dart';

class SharedPrefsSettings implements SettingsContract {
  SharedPrefsSettings(this.prefs);

  final SharedPreferences prefs;

  @override
  bool get darkMode => prefs.getBool("dark-mode") ?? false;

  @override
  set darkMode(bool v) {
    prefs.setBool("dark-mode", v).ignore();
  }
}
