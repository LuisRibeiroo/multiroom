sealed class PageState {}

class InitialState implements PageState {
  @override
  String toString() {
    return runtimeType.toString();
  }
}

class LoadingState implements PageState {
  @override
  String toString() {
    return runtimeType.toString();
  }
}

class SuccessState<R> implements PageState {
  const SuccessState({
    required this.data,
  });

  final R data;

  @override
  String toString() {
    return runtimeType.toString();
  }
}

class ErrorState<T extends Exception> implements PageState {
  const ErrorState({
    required this.exception,
  });

  final T exception;

  @override
  String toString() {
    return runtimeType.toString();
  }
}
