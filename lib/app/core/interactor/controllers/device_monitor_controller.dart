import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:signals/signals.dart';
import 'package:udp/udp.dart';

import '../../../../injector.dart';
import '../../enums/page_state.dart';
import '../../utils/datagram_data_parser.dart';
import '../repositories/settings_contract.dart';
import 'base_controller.dart';

class DeviceMonitorController extends BaseController {
  DeviceMonitorController() : super(InitialState());

  static const _scanDuration = Duration(seconds: 5);

  UDP? _udpServer;

  final _settings = injector.get<SettingsContract>();

  final isUdpListening = false.toSignal(debugLabel: "isUdpListening");

  Future<void> startUdpServer() async {
    await Permission.nearbyWifiDevices.request();

    if (isUdpListening.value) {
      return;
    }

    try {
      _udpServer = await UDP.bind(
        Endpoint.unicast(
          InternetAddress.anyIPv4,
          port: const Port(4055),
        ),
      );

      isUdpListening.value = true;
    } catch (exception) {
      logger.e(exception);
      setError(exception as Exception);
    }
  }

  void stopUdpServer() {
    if (_udpServer?.closed == false) {
      _udpServer?.close();
    }

    isUdpListening.value = false;
  }

  Future<void> scanDevices() async {
    await startUdpServer();

    _udpServer?.asStream(timeout: _scanDuration).listen(
      (datagram) {
        if (datagram == null) {
          return;
        }

        try {
          final (serialNumber, _) = DatagramDataParser.getSerialAndFirmware(datagram.data);
          logger.i("$serialNumber -> ${datagram.address.address}");

          _updateDeviceIp(serial: serialNumber, ip: datagram.address.address);
        } catch (exception) {
          logger.e("Datagram parse error [${datagram.address.address}]-> $exception");
        }
      },
      onDone: () {
        isUdpListening.value = false;
      },
    );

    await Future.delayed(_scanDuration);
  }

  void _updateDeviceIp({
    required String serial,
    required String ip,
  }) {
    final device = _settings.devices.firstWhereOrNull((d) => d.serialNumber == serial);

    if (device != null && ip != device.ip) {
      _settings.saveDevice(device: device.copyWith(ip: ip));
      logger.i("--> Updated device [${device.serialNumber}] to IP [$ip]");
    } else {
      logger.i("--> New device or same SN and IP");
    }
  }
}
