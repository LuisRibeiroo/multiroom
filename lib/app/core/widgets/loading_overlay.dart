import 'dart:async';

import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:toastification/toastification.dart';

import '../../../injector.dart';
import '../enums/page_state.dart';
import '../interactor/controllers/loading_overlay_controller.dart';

class LoadingOverlay extends StatefulWidget {
  const LoadingOverlay({
    super.key,
    required this.state,
    required this.child,
    this.dismissible = false,
    this.loadingWidget,
    this.currentIp = "",
    this.onTap,
    this.onSuccessState,
  });

  final Signal<PageState> state;
  final Widget child;
  final bool dismissible;
  final Widget? loadingWidget;
  final String currentIp;
  final Function()? onTap;
  final Function()? onSuccessState;

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay> {
  final _controller = injector.get<LoadingOverlayController>();

  @override
  void initState() {
    super.initState();

    scheduleMicrotask(() {
      _controller.disposables["${_controller.runtimeType}"] = [
        effect(() async {
          _controller.pageState.value = widget.state.value;

          if (_controller.pageState.value is ErrorState) {
            untracked(() {
              _controller.incrementErrorCounter();
            });

            toastification.show(
              title:
                  Text((_controller.pageState.value as ErrorState).exception.toString().replaceAll("Exception: ", "")),
              autoCloseDuration: const Duration(seconds: 4),
              style: ToastificationStyle.minimal,
              type: ToastificationType.error,
              closeOnClick: true,
            );

            if (_controller.errorCounter.peek() > 1) {
              _controller.startPulling();

              _controller.checkDeviceAvailability(
                pageState: widget.state,
                currentIp: widget.currentIp,
              );
            }
          } else {
            if (_controller.pageState.value is SuccessState) {
              untracked(() {
                _controller.resetErrorCounter();
                _controller.stopPulling();
              });

              widget.onSuccessState?.call();
            }
          }
        })
      ];
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
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: widget.onTap,
                    onDoubleTap: () {
                      widget.state.value = InitialState();
                    },
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
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
