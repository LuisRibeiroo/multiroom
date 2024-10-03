import 'dart:io';

class PlatformChecker {
  static bool get isMobile => Platform.isAndroid || Platform.isIOS;
}
