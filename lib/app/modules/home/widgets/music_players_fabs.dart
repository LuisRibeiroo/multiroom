import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

abstract class MusicPlayersFabs {
  static Future<void> _launchUrl(String url) async {
    final uri = Uri.parse("https://$url");

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  static _assetLogo(String fileName) => Image.asset(
        "assets/images/music_players/$fileName.png",
        width: 80,
        color: Colors.black,
      );

  static final children = [
    FloatingActionButton.extended(
      label: _assetLogo("spotify"),
      onPressed: () => _launchUrl('open.spotify.com'),
    ),
    FloatingActionButton.extended(
      label: _assetLogo("deezer"),
      onPressed: () => _launchUrl('deezer.com/br'),
    ),
    FloatingActionButton.extended(
      label: _assetLogo("amazon_music"),
      onPressed: () => _launchUrl('music.amazon.com'),
    ),
    FloatingActionButton.extended(
      label: _assetLogo("apple_music"),
      onPressed: () => _launchUrl('music.apple.com'),
    ),
    FloatingActionButton.extended(
      label: _assetLogo("yt_music"),
      onPressed: () => _launchUrl('music.youtube.com'),
    ),
  ];
}