import 'package:signals/signals_flutter.dart';

import '../../enums/page_state.dart';
import '../../utils/constants.dart';
import 'base_controller.dart';
import 'socket_mixin.dart';

class LoadingOverlayController extends BaseController with SocketMixin {
  LoadingOverlayController() : super(InitialState());

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
  }) async {
    pageState.value = LoadingState();
    this.pageState.value = pageState.value;

    try {
      await restartSocket(ip: currentIp);
      logger.i("[DBG] Device [$currentIp] -> ONLINE");

      pageState.value = const SuccessState(data: null);
      this.pageState.value = pageState.value;
    } catch (exception) {
      await Future.delayed(const Duration(seconds: defaultScanDuration ~/ 2));

      if (_needPulling) {
        logger.i("[DBG] Check availability at [$currentIp]");

        await checkDeviceAvailability(
          pageState: pageState,
          currentIp: currentIp,
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
