import 'dart:async';

import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:toastification/toastification.dart';

import '../enums/page_state.dart';

class LoadingOverlay extends StatefulWidget {
  const LoadingOverlay({
    super.key,
    required this.state,
    required this.child,
    this.dismissible = false,
    this.loadingWidget,
  });

  final Signal<PageState> state;
  final Widget child;
  final bool dismissible;
  final Widget? loadingWidget;

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay> {
  Function? _disposable;

  @override
  void initState() {
    super.initState();

    scheduleMicrotask(() {
      _disposable = effect(() {
        if (widget.state.value is ErrorState) {
          toastification.show(
            title: Text("${(widget.state.value as ErrorState).exception}"),
            autoCloseDuration: const Duration(seconds: 5),
            style: ToastificationStyle.minimal,
            type: ToastificationType.error,
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Watch(
      (_) => Stack(
        children: [
          widget.child,
          Visibility(
            visible: widget.state.value is LoadingState,
            child: Stack(
              children: [
                Opacity(
                  opacity: 0.4,
                  child: ModalBarrier(
                    color: Colors.black,
                    dismissible: widget.dismissible,
                  ),
                ),
                Visibility(
                  visible: widget.loadingWidget == null,
                  replacement: widget.loadingWidget ?? const SizedBox.shrink(),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _disposable?.call();

    super.dispose();
  }
}
