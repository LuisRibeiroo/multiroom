import "package:flutter/material.dart";
import "package:flutter_expandable_fab/flutter_expandable_fab.dart";
import "package:url_launcher/url_launcher.dart";

abstract class MusicPlayersFabs {
  static Map<String, ({String android, String ios, String url})> get _packages => {
        "spotify": (android: "com.spotify.music", ios: "spotify://", url: "open.spotify.com"),
        "deezer": (android: "deezer.android.app", ios: "deezer://", url: "deezer.com/br"),
        "amazon_music": (android: "com.amazon.mp3", ios: "amznmp3://", url: "music.amazon.com"),
        "apple_music": (android: "com.apple.android.music", ios: "music://", url: "music.apple.com"),
        "yt_music": (
          android: "com.google.android.apps.youtube.music",
          ios: "youtube-music://",
          url: "music.youtube.com"
        )
      };

  static Future<void> _launchUrl(GlobalKey<ExpandableFabState> key, String app) async {
    final appInfo = _packages[app]!;

    // if (PlatformChecker.isMobile) {
    //   if (await LaunchApp.isAppInstalled(
    //     androidPackageName: appInfo.android,
    //     iosUrlScheme: appInfo.ios,
    //   )) {
    //     await LaunchApp.openApp(
    //       androidPackageName: appInfo.android,
    //       iosUrlScheme: appInfo.ios,
    //       openStore: false,
    //     );

    //     return;
    //   } else {
    //     _openBrowser(app, appInfo.url);
    //   }
    // } else {
    _openBrowser(app, appInfo.url);
    // }

    final state = key.currentState;
    if (state != null) {
      debugPrint('isOpen:${state.isOpen}');
      state.toggle();
    }
  }

  static _openBrowser(String appName, String appUrl) async {
    final uri = Uri.parse("https://$appUrl");

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw "Could not launch $appName";
    }
  }

  static _assetLogo(String fileName) => Image.asset(
        "assets/images/music_players/$fileName.png",
        width: 80,
        color: Colors.black,
      );

  static children(GlobalKey<ExpandableFabState> key) => [
        FloatingActionButton.extended(
          heroTag: const ValueKey("spotify"),
          label: _assetLogo("spotify"),
          onPressed: () => _launchUrl(key, "spotify"),
        ),
        FloatingActionButton.extended(
          heroTag: const ValueKey("deezer"),
          key: const ValueKey("deezer"),
          label: _assetLogo("deezer"),
          onPressed: () => _launchUrl(key, "deezer"),
        ),
        FloatingActionButton.extended(
          heroTag: const ValueKey("amazon_music"),
          label: _assetLogo("amazon_music"),
          onPressed: () => _launchUrl(key, "amazon_music"),
        ),
        FloatingActionButton.extended(
          heroTag: const ValueKey("apple_music"),
          label: _assetLogo("apple_music"),
          onPressed: () => _launchUrl(key, "apple_music"),
        ),
        FloatingActionButton.extended(
          heroTag: const ValueKey("yt_music"),
          label: _assetLogo("yt_music"),
          onPressed: () => _launchUrl(key, "yt_music"),
        ),
      ];
}
