import 'package:signals/signals_flutter.dart';

import '../../enums/page_state.dart';
import '../../utils/mr_cmd_builder.dart';
import 'base_controller.dart';
import 'socket_mixin.dart';

class LoadingOverlayController extends BaseController with SocketMixin {
  LoadingOverlayController() : super(InitialState());

  final errorCounter = 0.toSignal(debugLabel: "errorCounter");
  final deviceAvailable = false.toSignal(debugLabel: "deviceAvailable");

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
      await socketSender(MrCmdBuilder.expansionMode);

      deviceAvailable.value = true;

      pageState.value = const SuccessState(data: null);
    } catch (exception) {
      deviceAvailable.value = false;
    }

    pageState.value = InitialState();
  }

  @override
  void dispose() {
    super.dispose();
    mixinDispose();

    errorCounter.value = errorCounter.initialValue;
    deviceAvailable.value = deviceAvailable.initialValue;
  }
}
