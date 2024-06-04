sealed class PageState {}

class InitialState implements PageState {}

class LoadingState implements PageState {}

class SuccessState<R> implements PageState {
  const SuccessState({
    required this.data,
  });

  final R data;
}

class ErrorState<T extends Exception> implements PageState {
  const ErrorState({
    required this.exception,
  });

  final T exception;
}
