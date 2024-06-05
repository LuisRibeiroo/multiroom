import 'dart:io';

import 'package:signals/signals_flutter.dart';

import '../../../../core/enums/page_state.dart';
import '../../../../core/interactor/controllers/base_controller.dart';

class HomePageController extends BaseController {
  HomePageController() : super(InitialState());

  late Socket _socket;

  final host = "127.0.0.1".toSignal(debugLabel: "host");
  final port = "4999".toSignal(debugLabel: "port");
  final isConnected = false.toSignal(debugLabel: "isConnected");

  Future<void> toggleConnection() async {
    if (isConnected.value) {
      _socket.close();
      isConnected.value = false;
    } else {
      try {
        _socket = await run(
          () => Socket.connect(
            host.value,
            int.parse(port.value),
            timeout: const Duration(seconds: 5),
          ),
        );

        isConnected.value = true;
      } catch (exception) {
        setError(exception as Exception);
      }
    }
  }
}
