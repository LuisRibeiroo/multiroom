import 'package:signals/signals_flutter.dart';

import '../../../../core/enums/page_state.dart';
import '../../../../core/extensions/string_extensions.dart';
import '../../../../core/interactor/controllers/base_controller.dart';

class HomePageController extends BaseController {
  HomePageController() : super(InitialState());

  final password = "".toSignal();

  void onTapAccess() {
    final test = "!Control@061".getMd5;

    run(
      () => test == password.value.getMd5,
      setSucces: true,
    );
  }
}
