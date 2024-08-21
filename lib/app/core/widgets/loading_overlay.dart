import 'dart:async';

import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:toastification/toastification.dart';

import '../../../injector.dart';
import '../enums/page_state.dart';
import '../interactor/controllers/loading_overlay_controller.dart';
import 'error_dialog.dart';

class LoadingOverlay extends StatefulWidget {
  const LoadingOverlay({
    super.key,
    required this.state,
    required this.child,
    this.dismissible = false,
    this.loadingWidget,
    this.currentIp = "",
  });

  final Signal<PageState> state;
  final Widget child;
  final bool dismissible;
  final Widget? loadingWidget;
  final String currentIp;

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay> {
  final _controller = injector.get<LoadingOverlayController>();

  @override
  void initState() {
    super.initState();

    scheduleMicrotask(() {
      _controller.disposables.add(effect(() {
        if (widget.state.value is ErrorState) {
          untracked(() {
            _controller.incrementErrorCounter();
          });

          if (_controller.errorCounter.peek() > 1) {
            return ErrorDialog.show(
              context: context,
              pageState: widget.state,
              currentIp: widget.currentIp,
            );
          }

          toastification.show(
            title: Text((widget.state.value as ErrorState).exception.toString().replaceAll("Exception: ", "")),
            autoCloseDuration: const Duration(seconds: 4),
            style: ToastificationStyle.minimal,
            type: ToastificationType.error,
          );
        } else {
          untracked(() {
            _controller.resetErrorCounter();
          });
        }
      }));
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
    _controller.dispose();

    super.dispose();
  }
}
