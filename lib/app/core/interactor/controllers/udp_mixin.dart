import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:udp/udp.dart';

mixin UdpMixin {
  UDP? _udpServer;

  bool running = false;

  Future<UDP> startServer() async {
    await Permission.nearbyWifiDevices.request();

    if (running) {
      return _udpServer!;
    }

    _udpServer = await UDP.bind(
      Endpoint.unicast(
        InternetAddress.anyIPv4,
        port: const Port(4055),
      ),
    );

    running = true;

    return _udpServer!;
  }

  void stopServer() {
    if (_udpServer?.closed == false) {
      _udpServer?.close();
    }

    running = false;
  }

  void mixinDispose() {
    _udpServer?.close();
    _udpServer = null;
  }
}
