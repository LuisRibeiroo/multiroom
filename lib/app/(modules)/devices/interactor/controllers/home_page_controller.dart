import 'dart:io';

import 'package:multiroom/app/core/models/zone_model.dart';
import 'package:signals/signals_flutter.dart';

import '../../../../core/enums/page_state.dart';
import '../../../../core/interactor/controllers/base_controller.dart';
import '../../../../core/models/input_model.dart';
import '../models/device_model.dart';

class HomePageController extends BaseController {
  HomePageController() : super(InitialState()) {
    device.subscribe((value) {
      if (value.isEmpty) {
        return;
      }

      currentZone.value = value.zones.first;
      currentInput.value = value.inputs.first;
    });
  }

  late Socket _socket;

  final host = "127.0.0.1".toSignal(debugLabel: "host");
  final port = "4998".toSignal(debugLabel: "port");
  final isConnected = false.toSignal(debugLabel: "isConnected");
  final device = DeviceModel.empty().toSignal(debugLabel: "device");
  final currentZone = ZoneModel.empty().toSignal(debugLabel: "currentZone");
  final currentInput = InputModel.empty().toSignal(debugLabel: "currentInput");

  Future<void> toggleConnection() async {
    if (isConnected.value) {
      _socket.close();
      isConnected.value = false;

      device.value = DeviceModel.empty();
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

        device.value = DeviceModel.builder(
          name: "Master 1",
          ip: host.value,
          port: int.parse(port.value),
        );
      } catch (exception) {
        setError(exception as Exception);
      }
    }
  }
}
