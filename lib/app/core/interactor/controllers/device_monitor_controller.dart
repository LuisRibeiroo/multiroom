import 'dart:async';

import 'package:async/async.dart';
import 'package:collection/collection.dart';
import 'package:signals/signals_flutter.dart';

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

  String _callerName = "";

  Timer? _timer;

  final hasStateChanges = false.asSignal(debugLabel: "monitorHasStateChanges");
  CancelableOperation? _cancelableOperation;

  Future<void> scanDevices({
    Duration duration = const Duration(seconds: defaultScanDuration),
    bool updateIp = false,
    bool updateFirmware = false,
    bool updateActives = false,
    bool awaitFinish = false,
    Function()? onFinishCallback,
  }) async {
    final udp = await startServer();
    _serialSet.clear();

    udp.asStream(timeout: duration).listen(
      (datagram) {
        if (datagram == null) {
          return;
        }

        try {
          final (serialNumber, firmware, _) = DatagramDataParser.getSerialMacAndFirmware(datagram.data);

          if (updateIp) {
            _updateDeviceIpAndFirmware(
              serial: serialNumber,
              ip: datagram.address.address,
              firmware: firmware,
            );
          }

          logger.d("MONITOR [$_callerName] --> $serialNumber -> ${datagram.address.address}");
          // if (_serialSet.contains(serialNumber)) {
          //   return;
          // }

          _serialSet.add(serialNumber);
        } catch (exception) {
          logger.e("Datagram parse error [${datagram.address.address}]-> $exception");
        }
      },
      onDone: () {
        stopServer();

        if (updateActives) {
          _updateActives();
        }

        _serialSet.clear();

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
    int? cycleDuration,
  }) async {
    if (isRunning && _callerName == callerName) {
      return;
    }

    if (isRunning && _callerName != callerName) {
      logger.i("MONITOR --> Updating caller from [$_callerName] to [$callerName]");

      hasStateChanges.overrideWith(false);
      stopDeviceMonitor();
      stopServer();
    }

    isRunning = true;
    _callerName = callerName;

    final interval =
        Duration(milliseconds: ((cycleDuration ?? defaultScanDuration).clamp(defaultScanDuration, 20) * 1000).toInt());
    logger.i("MONITOR [$_callerName] --> START [${interval.inMilliseconds}ms]");

    scanDevices(
      updateActives: true,
      updateIp: true,
      updateFirmware: true,
      onFinishCallback: cycleCallback,
    );

    _timer = Timer.periodic(interval, (timer) async {
      _cancelableOperation = CancelableOperation.fromFuture(
        onCancel: () {
          timer.cancel();
          stopDeviceMonitor();
          stopServer();
        },
        scanDevices(
          duration: interval,
          awaitFinish: true,
          updateActives: true,
          updateIp: true,
          onFinishCallback: cycleCallback,
        ),
      );

      await _cancelableOperation?.valueOrCancellation();
    });
  }

  void stopDeviceMonitor({bool stopServer = false}) {
    if (stopServer) {
      this.stopServer();
    }

    _cancelableOperation?.cancel();
    _timer?.cancel();
    _timer = null;

    logger.i("MONITOR [$_callerName] --> STOP");
    isRunning = false;
  }

  void ingestStateChanges() {
    logger.i("MONITOR [$_callerName] --> Changes ingested");

    hasStateChanges.value = false;
  }

  void _updateDeviceIpAndFirmware({
    required String serial,
    required String ip,
    required String firmware,
  }) {
    final device = _settings.devices.firstWhereOrNull((d) => d.serialNumber == serial);

    if (device != null && (ip != device.ip || firmware != device.version)) {
      _settings.saveDevice(device: device.copyWith(ip: ip, version: firmware));
      logger.i("MONITOR --> Updated device [${device.serialNumber}] to IP [$ip] with version [$firmware]");

      hasStateChanges.value = true;
    }
  }

  void _updateActives() {
    for (final device in _settings.devices) {
      bool active = _serialSet.contains(device.serialNumber);

      if (active == device.active) {
        continue;
      }

      _settings.saveDevice(device: device.copyWith(active: active));
      logger.i("MONITOR [$_callerName] --> [${device.serialNumber}] set ${active ? "ONLINE" : "OFFLINE"}");

      hasStateChanges.value = true;
    }

    // _serialSet.clear();
    if (isRunning) {
      if (hasStateChanges.value == false) {
        logger.i("MONITOR [$_callerName] --> No device state change");
      } else {
        logger.i("MONITOR [$_callerName] --> Changes waiting ingestion");
      }
    }
  }

  @override
  void dispose() {
    mixinDispose();
    stopDeviceMonitor();

    super.dispose();
  }
}
