import 'package:signals/signals_flutter.dart';

import '../../enums/page_state.dart';
import '../../utils/mr_cmd_builder.dart';
import 'base_controller.dart';
import 'socket_mixin.dart';

class ErrorDialogController extends BaseController with SocketMixin {
  ErrorDialogController() : super(InitialState());

  Future<bool> checkDeviceAvailability({
    required Signal<PageState> pageState,
    required String currentIp,
  }) async {
    pageState.value = LoadingState();

    try {
      await restartSocket(ip: currentIp);
      await socketSender(MrCmdBuilder.expansionMode);

      pageState.value = InitialState();

      return true;
    } catch (exception) {
      pageState.value = InitialState();

      return false;
    }
  }

  @override
  void dispose() {
    super.dispose();
    mixinDispose();
  }
}
