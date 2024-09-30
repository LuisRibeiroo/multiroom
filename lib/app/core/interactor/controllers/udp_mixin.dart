import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:udp/udp.dart';

mixin UdpMixin {
  UDP? _udpServer;

  bool get running => _udpServer != null && !_udpServer!.closed;

  Future<UDP> startServer() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await Permission.nearbyWifiDevices.request();
    }

    if (_udpServer != null) {
      _udpServer!.close();
      _udpServer = null;
    }

    _udpServer = await UDP.bind(
      Endpoint.unicast(
        InternetAddress.anyIPv4,
        port: const Port(4055),
      ),
    );

    return _udpServer!;
  }

  void stopServer() {
    if (_udpServer?.closed == false) {
      _udpServer?.close();
    }

    _udpServer = null;
  }

  void mixinDispose() {
    _udpServer?.close();
    _udpServer = null;
  }
}
