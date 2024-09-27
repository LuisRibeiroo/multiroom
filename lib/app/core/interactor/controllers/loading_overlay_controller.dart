import 'package:collection/collection.dart';
import 'package:signals/signals_flutter.dart';

import '../../../../injector.dart';
import '../../enums/page_state.dart';
import '../../utils/constants.dart';
import '../repositories/settings_contract.dart';
import 'base_controller.dart';
import 'device_monitor_controller.dart';

class LoadingOverlayController extends BaseController {
  LoadingOverlayController() : super(InitialState());

  final _settings = injector.get<SettingsContract>();
  final pageState = Signal<PageState>(InitialState(), debugLabel: "overlayPageState");
  final errorCounter = 0.toSignal(debugLabel: "errorCounter");

  final _monitorController = injector.get<DeviceMonitorController>();

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
      await _monitorController.startDeviceMonitor(callerName: "LoadingOverlayController");
    }

    await _checkIpStateOnMonitor(pageState: pageState, ip: currentIp);
  }

  Future<void> _checkIpStateOnMonitor({
    required Signal<PageState> pageState,
    required String ip,
  }) async {
    if (_monitorController.hasStateChanges) {
      final device = _settings.devices.firstWhereOrNull((d) => d.ip == ip);

      if (device != null && device.active) {
        _monitorController.stopDeviceMonitor();

        pageState.value = const SuccessState(data: null);
        this.pageState.value = pageState.value;
      } else {
        logger.i("LOADER --> Waiting [$ip] online on MONITOR");
        await Future.delayed(defaultScanDuration);

        await checkDeviceAvailability(
          pageState: pageState,
          currentIp: ip,
        );
      }
    }
  }

  @override
  void dispose() {
    super.dispose();

    errorCounter.value = errorCounter.initialValue;
    pageState.value = pageState.initialValue;
    _monitorController.stopDeviceMonitor();
  }
}
