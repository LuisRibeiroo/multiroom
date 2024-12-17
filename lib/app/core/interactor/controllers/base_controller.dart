import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:multiroom/app/core/models/socket_connection.dart';
import 'package:signals/signals_flutter.dart';

import '../../enums/page_state.dart';

abstract class BaseController<T extends PageState> implements ValueListenable<PageState> {
  /// Cria uma instância de `BaseController` com um estado inicial fornecido.
  ///
  /// [initialState] O estado inicial para o controlador.
  BaseController(PageState initialState) {
    _stateNotifier = SignalValueNotifier<PageState>(
      initialState,
      debugLabel: "BaseControllerState",
      autoDispose: true,
    );
  }

  final connections = <String, SocketConnection>{};

  final logger = Logger(
    printer: SimplePrinter(
      printTime: true,
      colors: false,
    ),
  );

  final disposables = <String, List<Function?>>{};

  late final SignalValueNotifier<PageState> _stateNotifier;

  /// Obtém o estado atual mantido pelo `_stateNotifier`.
  @override
  PageState get value => _stateNotifier.value;

  /// Obtém o estado atual mantido pelo `_stateNotifier`.
  Signal<PageState> get state => _stateNotifier;

  /// Adiciona um listener que será chamado sempre que o estado mudar.
  ///
  /// [listener] A função de callback a ser chamada nas mudanças de estado.
  @override
  void addListener(VoidCallback listener) {
    _stateNotifier.addListener(listener);
  }

  /// Remove um listener previamente adicionado.
  ///
  /// [listener] A função de callback a ser removida.
  @override
  void removeListener(VoidCallback listener) {
    _stateNotifier.removeListener(listener);
  }

  /// Atualiza o estado atual com um novo estado.
  ///
  /// [newState] O novo estado para atualizar.
  void _update(PageState newState) {
    _stateNotifier.value = newState;
  }

  Future<R> run<R>(
    Function action, {
    bool setError = false,
  }) async {
    try {
      _update(LoadingState());

      final result = await action();

      _update(InitialState());

      return result as R;
    } catch (e) {
      _update(setError ? ErrorState(exception: e as Exception) : InitialState());

      return Future.error(e);
    }
  }

  void setError(Exception exception) {
    _update(ErrorState(exception: exception));
    logger.e(
      "$BaseController.setError --> [$exception]",
      stackTrace: StackTrace.current,
    );
  }

  @mustCallSuper
  void baseDispose({required String key}) {
    _update(InitialState());

    for (final d in disposables[key] ?? []) {
      d?.call();
    }
  }
}
