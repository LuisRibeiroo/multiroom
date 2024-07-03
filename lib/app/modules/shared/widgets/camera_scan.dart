import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/extensions/build_context_extensions.dart';
import '../../../core/extensions/number_extensions.dart';

class CameraScan extends StatefulWidget {
  const CameraScan({
    super.key,
    required this.onDetectBarCode,
  });

  final Function(String) onDetectBarCode;

  @override
  State<CameraScan> createState() => _CameraScanState();
}

class _CameraScanState extends State<CameraScan> with WidgetsBindingObserver {
  final _scanController = MobileScannerController(
    formats: [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  @override
  void initState() {
    super.initState();
    // Start listening to lifecycle changes.
    WidgetsBinding.instance.addObserver(this);

    // Finally, start the scanner itself.
    unawaited(_scanController.start());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.qr_code_scanner_rounded,
                size: 36,
              ),
              8.asSpace,
              Expanded(
                child: Text(
                  "ou aponte a câmera para o QRCode compartilhado pelo outro app",
                  style: context.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        Center(
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              border: Border.all(
                color: context.colorScheme.inversePrimary,
                width: 6,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: MobileScanner(
                controller: _scanController,
                onDetect: (b) => widget.onDetectBarCode(b.barcodes.first.displayValue ?? ""),
                placeholderBuilder: (p0, p1) => const Center(child: CircularProgressIndicator()),
                errorBuilder: (p0, p1, p2) => Center(
                  child: IconButton.filled(
                    icon: const Icon(Icons.restart_alt_rounded),
                    onPressed: _scanController.start,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // If the controller is not ready, do not try to start or stop it.
    // Permission dialogs can trigger lifecycle changes before the controller is ready.
    if (!_scanController.value.isInitialized) {
      return;
    }

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;

      case AppLifecycleState.resumed:
        // Restart the scanner when the app is resumed.
        // Don't forget to resume listening to the barcode events.
        // _subscription = _scanController.barcodes.listen(_handleBarcode);

        unawaited(_scanController.start());
        break;

      case AppLifecycleState.inactive:
        unawaited(_scanController.stop());

        break;
    }
  }

  @override
  Future<void> dispose() async {
    // Stop listening to lifecycle changes.
    WidgetsBinding.instance.removeObserver(this);

    // Dispose the widget itself.
    super.dispose();
    // Finally, dispose of the controller.
    await _scanController.dispose();
  }
}
