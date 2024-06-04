import 'dart:io';

import 'package:signals/signals_flutter.dart';

import '../../../../core/enums/page_state.dart';
import '../../../../core/interactor/controllers/base_controller.dart';

class HomePageController extends BaseController {
  HomePageController() : super(InitialState());

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
        _socket = await run(
          () => Future.delayed(
            const Duration(seconds: 2),
            () => Socket.connect(
              host.value,
              port.value,
              timeout: const Duration(seconds: 5),
            ),
          ),
        );

        isConnected.value = true;
      } catch (exception) {
        setError(exception as Exception);
      }
    }
  }
}
