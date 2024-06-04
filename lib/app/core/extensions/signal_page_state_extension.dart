import 'package:signals/signals_flutter.dart';

import '../enums/page_state.dart';

extension SignalPageStateExt on Signal<PageState> {
  Future<T> run<T>(Function action, {bool setSucces = false}) async {
    try {
      value = PageState.loading;

      final result = await action();

      value = setSucces ? PageState.success : PageState.idle;

      return result as T;
    } catch (e) {
      value = setSucces ? PageState.failure : PageState.idle;

      return Future.error(e);
    }
  }
}
