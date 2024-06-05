import 'dart:io';

import 'package:multiroom/app/core/extensions/list_extensions.dart';
import 'package:multiroom/app/core/models/equalizer_model.dart';
import 'package:multiroom/app/core/models/frequency.dart';
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

      untracked(() {
        currentZone.value = value.zones.first;
        currentInput.value = value.inputs.first;

        equalizers.addOrReplace(currentZone.value.equalizer);
      });
    });

    currentZone.subscribe((value) {
      if (value.isEmpty) {
        return;
      }

      final idx = device.value.zones
          .indexWhere((zone) => currentZone.value.name == zone.name);

      device.value.zones[idx] = value;
    });

    currentInput.subscribe((value) {
      if (value.isEmpty) {
        return;
      }

      final idx = device.value.inputs
          .indexWhere((input) => currentInput.value.name == input.name);

      device.value.inputs[idx] = value;
    });
  }

  late Socket _socket;

  final equalizers = listSignal([
    EqualizerModel.builder(name: "Rock", value: 80),
    EqualizerModel.builder(name: "Pop", value: 60),
    EqualizerModel.builder(name: "Jazz", value: 65),
    EqualizerModel.builder(name: "Flat", value: 50),
  ]);

  final host = "192.168.0.12".toSignal(debugLabel: "host");
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

  void setCurrentZone(ZoneModel zone) {
    currentZone.value = zone;
  }

  void setCurrentInput(InputModel input) {
    currentInput.value = input;
  }

  void setBalance(double balance) {
    currentZone.value = currentZone.value.copyWith(balance: balance.toInt());
  }

  void setVolume(double volume) {
    currentZone.value = currentZone.value.copyWith(volume: volume.toInt());
  }

  void setEqualizer(int equalizerIndex) {
    currentZone.value =
        currentZone.value.copyWith(equalizer: equalizers[equalizerIndex]);
  }

  void setFrequency(
    EqualizerModel equalizer,
    Frequency frequency,
  ) {
    final freqIndex =
        equalizer.frequencies.indexWhere((f) => f.name == frequency.name);
    final tempList = List<Frequency>.from(equalizer.frequencies);

    tempList[freqIndex] = equalizer.frequencies[freqIndex]
        .copyWith(value: frequency.value.toInt());

    currentZone.value = currentZone.value
        .copyWith(equalizer: equalizer.copyWith(frequencies: tempList));
  }
}
