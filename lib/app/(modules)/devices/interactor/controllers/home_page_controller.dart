import 'dart:io';

import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:toastification/toastification.dart';

class HomePageController {
  late Socket _socket;

  
  final host = "127.000.000.001".toSignal(debugLabel: "host");
  final port = 4999.toSignal(debugLabel: "port");
  final isConnected = false.toSignal(debugLabel: "isConnected");

  Future<void> toggleConnection() async {
    if (isConnected.value) {
      _socket.close();
      isConnected.value = false;
    } else {
      try {
        _socket = await Socket.connect(
          host.value,
          port.value,
          timeout: const Duration(seconds: 5),
        );

        isConnected.value = true;
      } catch (exception) {
        toastification.show(
          title: Text("$exception"),
          autoCloseDuration: const Duration(seconds: 5),
          style: ToastificationStyle.minimal,
          type: ToastificationType.error,
        );
      }
    }
  }
}
