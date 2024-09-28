import 'package:collection/collection.dart';
import 'package:logger/logger.dart';
import 'package:signals/signals_flutter.dart';

import '../../../../injector.dart';
import '../../enums/page_state.dart';
import '../../utils/constants.dart';
import '../repositories/settings_contract.dart';
import 'device_monitor_controller.dart';

class LoadingOverlayController {
  final _settings = injector.get<SettingsContract>();
  final pageState = Signal<PageState>(InitialState(), debugLabel: "overlayPageState");
  final errorCounter = 0.toSignal(debugLabel: "errorCounter");

  final _monitorController = injector.get<DeviceMonitorController>();

  bool get monitorRunning => _monitorController.isRunning;

  void incrementErrorCounter() {
    errorCounter.value++;
  }

  void resetErrorCounter() {
    errorCounter.value = errorCounter.initialValue;
  }

  Future<void> checkDeviceAvailability({
    required Signal<PageState> pageState,
    required String currentIp,
  }) async {
    pageState.value = LoadingState();
    this.pageState.value = pageState.value;

    if (_monitorController.isRunning == false) {
      // _monitorController.stopDeviceMonitor();
      await _monitorController.startDeviceMonitor(callerName: "LoadingOverlayController");
    }

    await _checkIpStateOnMonitor(pageState: pageState, ip: currentIp);
  }

  Future<void> _checkIpStateOnMonitor({
    required Signal<PageState> pageState,
    required String ip,
  }) async {
    final device = _settings.devices.firstWhereOrNull((d) => d.ip == ip);

    if (device != null && device.active) {
      // _monitorController.stopDeviceMonitor();
      resetErrorCounter();

      pageState.value = const SuccessState(data: null);
      this.pageState.value = pageState.value;
    } else {
      Logger(printer: SimplePrinter(printTime: false, colors: false)).i("LOADER --> Waiting [$ip] online on MONITOR");
      await Future.delayed(defaultScanDuration);

      await _checkIpStateOnMonitor(pageState: pageState, ip: ip);
    }
  }

  void dispose() {
    // super.dispose();

    errorCounter.value = errorCounter.initialValue;
    pageState.value = pageState.initialValue;
    // _monitorController.stopDeviceMonitor();
  }
}
