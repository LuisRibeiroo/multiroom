import "package:external_app_launcher/external_app_launcher.dart";
import "package:flutter/material.dart";
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

  static Future<void> _launchUrl(String app) async {
    final appInfo = _packages[app]!;

    if (await LaunchApp.isAppInstalled(
      androidPackageName: appInfo.android,
      iosUrlScheme: appInfo.ios,
    )) {
      await LaunchApp.openApp(
        androidPackageName: appInfo.android,
        iosUrlScheme: appInfo.ios,
        openStore: false,
      );

      return;
    } else {
      final uri = Uri.parse("https://${appInfo.url}");

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw "Could not launch $app";
      }
    }
  }

  static _assetLogo(String fileName) => Image.asset(
        "assets/images/music_players/$fileName.png",
        width: 80,
        color: Colors.black,
      );

  static final children = [
    FloatingActionButton.extended(
      heroTag: const ValueKey("spotify"),
      label: _assetLogo("spotify"),
      onPressed: () => _launchUrl("spotify"),
    ),
    FloatingActionButton.extended(
      heroTag: const ValueKey("deezer"),
      key: const ValueKey("deezer"),
      label: _assetLogo("deezer"),
      onPressed: () => _launchUrl("deezer"),
    ),
    FloatingActionButton.extended(
      heroTag: const ValueKey("amazon_music"),
      label: _assetLogo("amazon_music"),
      onPressed: () => _launchUrl("amazon_music"),
    ),
    FloatingActionButton.extended(
      heroTag: const ValueKey("apple_music"),
      label: _assetLogo("apple_music"),
      onPressed: () => _launchUrl("apple_music"),
    ),
    FloatingActionButton.extended(
      heroTag: const ValueKey("yt_music"),
      label: _assetLogo("yt_music"),
      onPressed: () => _launchUrl("yt_music"),
    ),
  ];
}
