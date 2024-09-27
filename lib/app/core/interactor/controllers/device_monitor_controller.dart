import 'dart:async';

import 'package:async/async.dart';
import 'package:collection/collection.dart';

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

  final _serialSet = <String>{};
  bool isRunning = false;
  Timer? _timer;

  bool hasStateChanges = false;
  CancelableOperation? _cancelableOperation;

  Future<void> scanDevices({
    required String callerName,
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

          logger.i("MONITOR [$callerName] --> $serialNumber -> ${datagram.address.address}");
          _serialSet.add(serialNumber);

          if (updateIp) {
            _updateDeviceIp(serial: serialNumber, ip: datagram.address.address);
          }

          if (updateActives) {
            _updateActives(callerName: callerName);
          }
        } catch (exception) {
          logger.e("Datagram parse error [${datagram.address.address}]-> $exception");
        }
      },
      onDone: () {
        stopServer();

        if (updateActives) {
          _updateActives(callerName: callerName);
        }

        onFinishCallback?.call();
      },
    );

    if (awaitFinish) {
      await Future.delayed(duration);
    }
  }

  Future<void> startDeviceMonitor({
    required String callerName,
    Function()? cycleCallback,
  }) async {
    final interval = defaultScanDuration * 2;
    logger.i("MONITOR [$callerName] --> START [${interval.inSeconds}s]");
    isRunning = true;

    _timer = Timer.periodic(interval, (timer) async {
      _cancelableOperation = CancelableOperation.fromFuture(
        onCancel: () {
          timer.cancel();
          isRunning = false;
          stopServer();
        },
        scanDevices(
          callerName: callerName,
          updateActives: true,
          updateIp: true,
          onFinishCallback: cycleCallback,
        ),
      );

      await _cancelableOperation?.valueOrCancellation();
    });
  }

  void stopDeviceMonitor() {
    _cancelableOperation?.cancel();
    _timer?.cancel();

    logger.i("MONITOR --> STOP");
    isRunning = false;
  }

  void ingestStateChanges() {
    hasStateChanges = false;
    logger.i("MONITOR --> Changes ingested");
  }

  void _updateDeviceIp({
    required String serial,
    required String ip,
  }) {
    final device = _settings.devices.firstWhereOrNull((d) => d.serialNumber == serial);

    if (device != null && ip != device.ip) {
      _settings.saveDevice(device: device.copyWith(ip: ip));
      logger.i("MONITOR --> Updated device [${device.serialNumber}] to IP [$ip]");
      hasStateChanges = true;
    }
  }

  void _updateActives({required String callerName}) {
    for (final device in _settings.devices) {
      bool active = _serialSet.contains(device.serialNumber);

      if (active == device.active) {
        continue;
      }

      hasStateChanges = true;
      _settings.saveDevice(device: device.copyWith(active: active));
      logger.i("MONITOR [$callerName] --> [${device.serialNumber}] set ${active ? "ONLINE" : "OFFLINE"}");
    }

    if (hasStateChanges == false) {
      logger.i("MONITOR [$callerName] --> No device state change");
    } else {
      logger.i("MONITOR [$callerName] --> Changes waiting to be ingest");
    }
  }

  @override
  void dispose() {
    mixinDispose();
    stopDeviceMonitor();

    super.dispose();
  }
}
