import 'package:signals/signals_flutter.dart';

import '../../enums/page_state.dart';
import 'base_controller.dart';
import 'socket_mixin.dart';

class LoadingOverlayController extends BaseController with SocketMixin {
  LoadingOverlayController() : super(InitialState());

  final errorCounter = 0.toSignal(debugLabel: "errorCounter");

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

    try {
      await restartSocket(ip: currentIp);
      // await socketSender(MrCmdBuilder.firmwareVersion);

      pageState.value = const SuccessState(data: null);
    } catch (exception) {
      await Future.delayed(const Duration(seconds: 3));
      logger.i("Efetuando nova tentativa de comunicação com o ip: $currentIp");

      checkDeviceAvailability(pageState: pageState, currentIp: currentIp);
    }
  }

  @override
  void dispose() {
    super.dispose();
    mixinDispose();

    errorCounter.value = errorCounter.initialValue;
  }
}
