import 'package:signals/signals_flutter.dart';

import '../../../../injector.dart';
import '../../../core/enums/page_state.dart';
import '../../../core/extensions/string_extensions.dart';
import '../../../core/interactor/controllers/base_controller.dart';
import '../../../core/interactor/repositories/settings_contract.dart';

class OptionsBottomSheetController extends BaseController {
  OptionsBottomSheetController() : super(InitialState()) {
    disposables.add(
      effect(
        () {
          password.value;
          errorMessage.value = errorMessage.initialValue;
        },
      ),
    );
  }

  final settings = injector.get<SettingsContract>();
  final password = "".toSignal(debugLabel: "password");
  final errorMessage = "".toSignal(debugLabel: "errorMessage");
  final isPasswordVisible = false.toSignal(debugLabel: "isPasswordVisible");

  bool onTapAccess() {
    /// !Control@061
    if (settings.technicianAccessHash == password.value.getMd5) {
      // if ("123".getMd5 == password.value.getMd5) {
      // state.value = const SuccessState(data: "techAccess");
      return true;
    } else {
      errorMessage.value = "Senha inválida";
      return false;
    }
  }

  void onTogglePassword() => isPasswordVisible.value = !isPasswordVisible.value;

  @override
  void dispose() {
    super.dispose();

    password.value = password.initialValue;
    errorMessage.value = errorMessage.initialValue;
    isPasswordVisible.value = isPasswordVisible.initialValue;
  }
}
