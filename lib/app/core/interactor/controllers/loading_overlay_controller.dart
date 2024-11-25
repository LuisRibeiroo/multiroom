import 'package:collection/collection.dart';
import 'package:multiroom/app/core/interactor/repositories/settings_contract.dart';
import 'package:signals/signals_flutter.dart';

import '../../../../injector.dart';
import '../../enums/page_state.dart';
import '../../utils/constants.dart';
import 'base_controller.dart';
import 'device_monitor_controller.dart';
import 'socket_mixin.dart';

class LoadingOverlayController extends BaseController with SocketMixin {
  LoadingOverlayController() : super(InitialState());

  final _monitorController = injector.get<DeviceMonitorController>();
  final _settings = injector.get<SettingsContract>();

  final pageState = Signal<PageState>(InitialState(), debugLabel: "overlayPageState");
  final errorCounter = 0.asSignal(debugLabel: "errorCounter");
  bool _needPulling = false;

  void incrementErrorCounter() {
    errorCounter.value++;
  }

  void resetErrorCounter() {
    errorCounter.value = errorCounter.initialValue;
  }

  void startPulling() => _needPulling = true;
  void stopPulling() => _needPulling = false;

  Future<void> checkDeviceAvailability({
    required Signal<PageState> pageState,
    required String currentIp,
    required String macAddress,
  }) async {
    pageState.value = LoadingState();
    this.pageState.value = pageState.value;

    try {
      _monitorController.startDeviceMonitor(callerName: runtimeType.toString());

      await restartSocket(ip: currentIp);
      logger.i("[DBG] Device [$currentIp] -> ONLINE");

      _monitorController.stopDeviceMonitor();

      pageState.value = const SuccessState(data: null);
      this.pageState.value = pageState.value;
    } catch (exception) {
      await Future.delayed(const Duration(seconds: defaultScanDuration ~/ 2));

      if (_needPulling) {
        final device = _settings.devices.firstWhereOrNull((d) => d.macAddress == macAddress);
        final newIp = device?.ip ?? currentIp;

        logger.i("[DBG] Check availability at [$newIp]");

        await checkDeviceAvailability(
          pageState: pageState,
          currentIp: newIp,
          macAddress: macAddress,
        );
      }
    }
  }

  void dispose() {
    super.baseDispose(key: "$runtimeType");

    errorCounter.value = errorCounter.initialValue;
    pageState.value = pageState.initialValue;
  }
}
