import 'package:signals/signals_flutter.dart';

import '../../../../core/enums/page_state.dart';
import '../../../../core/extensions/string_extensions.dart';
import '../../../../core/interactor/controllers/base_controller.dart';

class HomePageController extends BaseController {
  HomePageController() : super(InitialState()) {
    password.subscribe((value) {
      errorMessage.value = "";
    });
  }

  final password = "".toSignal(debugLabel: "password");
  final errorMessage = "".toSignal(debugLabel: "errorMessage");

  void onTapAccess() {
    // final test = "!Control@061".getMd5;
    final test = "123".getMd5;

    // state.value =
    //     test == password.value ? const SuccessState(data: null) : ErrorState(exception: Exception("Senha inválida"));

    if (test == password.value.getMd5) {
      state.value = const SuccessState(data: null);
    } else {
      errorMessage.value = "Senha inválida";
    }
  }
}
