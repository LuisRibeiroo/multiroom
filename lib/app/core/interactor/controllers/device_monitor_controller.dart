import 'dart:async';

import 'package:collection/collection.dart';
import 'package:signals/signals.dart';

import '../../../../injector.dart';
import '../../enums/page_state.dart';
import '../../utils/constants.dart';
import '../../utils/datagram_data_parser.dart';
import '../repositories/settings_contract.dart';
import 'base_controller.dart';
import 'udp_mixin.dart';

class DeviceMonitorController extends BaseController with UdpMixin {
  DeviceMonitorController() : super(InitialState());

  final _settings = injector.get<SettingsContract>();

  final _serialSet = setSignal(<String>{}, debugLabel: "_serialSet");

  Future<void> scanDevices({
    Duration duration = defaultScanDuration,
    bool updateIp = false,
    bool updateActives = false,
    bool awaitFinish = false,
    Function()? onFinishCallback,
  }) async {
    final server = await startServer();
    _serialSet.clear();

    server.asStream(timeout: duration).listen(
      (datagram) {
        if (datagram == null) {
          return;
        }

        try {
          final (serialNumber, _) = DatagramDataParser.getSerialAndFirmware(datagram.data);

          if (_serialSet.contains(serialNumber)) {
            return;
          }

          logger.i("$serialNumber -> ${datagram.address.address}");
          _serialSet.add(serialNumber);

          if (updateIp) {
            _updateDeviceIp(serial: serialNumber, ip: datagram.address.address);
          }
        } catch (exception) {
          logger.e("Datagram parse error [${datagram.address.address}]-> $exception");
        }
      },
      onDone: () {
        stopServer();

        if (updateActives) {
          _updateActives();
        }

        onFinishCallback?.call();
      },
    );

    if (awaitFinish) {
      await Future.delayed(duration);
    }
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

  void _updateActives() {
    for (final device in _settings.devices) {
      bool active = _serialSet.contains(device.serialNumber);

      _settings.saveDevice(device: device.copyWith(active: active));
      logger.i("--> [${device.serialNumber}] set ${active ? "ONLINE" : "OFFLINE"}");
    }
  }
}
