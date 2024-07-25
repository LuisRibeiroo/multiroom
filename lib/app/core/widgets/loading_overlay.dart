import 'dart:async';

import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:toastification/toastification.dart';

import '../../../injector.dart';
import '../../modules/widgets/about_bottom_sheet.dart';
import '../enums/page_state.dart';
import '../extensions/build_context_extensions.dart';
import '../extensions/number_extensions.dart';
import '../interactor/controllers/loading_overlay_controller.dart';
import 'app_button.dart';

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

  void _showDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_rounded,
                    color: context.colorScheme.error,
                  ),
                  12.asSpace,
                  Text(
                    "Erro de comunicação com o Multiroom",
                    style: context.textTheme.titleMedium,
                  ),
                ],
              ),
              24.asSpace,
              Text(
                "Verifique se o dispositivo está ligado e conectado corretamente à rede.",
                style: context.textTheme.bodyMedium,
                textAlign: TextAlign.justify,
              ),
              Text(
                "Caso o problema persista, entre em contato com o suporte técnico.",
                style: context.textTheme.bodyMedium,
                textAlign: TextAlign.justify,
              ),
              32.asSpace,
              Row(
                children: [
                  Flexible(
                    child: AppButton(
                      type: ButtonType.secondary,
                      text: "Suporte",
                      onPressed: () {
                        Navigator.of(context).pop();

                        context.showCustomModalBottomSheet(
                          child: const AboutBottomSheet(),
                        );
                      },
                    ),
                  ),
                  24.asSpace,
                  Expanded(
                    child: AppButton(
                      text: "Testar comunicação",
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await _controller.checkDeviceAvailability(
                          pageState: widget.state,
                          currentIp: widget.currentIp,
                        );

                        if (_controller.deviceAvailable.value) {
                          toastification.show(
                            title: const Text("Dispositivo OK!"),
                            autoCloseDuration: const Duration(seconds: 2),
                            style: ToastificationStyle.minimal,
                            type: ToastificationType.success,
                          );
                        } else {
                          _showDialog();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    scheduleMicrotask(() {
      _controller.disposables.add(effect(() {
        if (widget.state.value is ErrorState) {
          untracked(() {
            _controller.incrementErrorCounter();
          });

          if (_controller.errorCounter.peek() > 2) {
            _showDialog();
            return;
          }

          toastification.show(
            title: Text("${(widget.state.value as ErrorState).exception}"),
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
