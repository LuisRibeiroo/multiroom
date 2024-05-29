import 'package:signals/signals.dart';

import 'device_model.dart';
import 'equalization_model.dart';

final devicesList = listSignal<DeviceModel>([]);

final equalizations = [
  EqualizationModel(
    name: "Rock",
    values: List.generate(10, (index) => 80.0.toSignal()),
  ),
  EqualizationModel(
    name: "Jazz",
    values: List.generate(10, (index) => 10.0.toSignal()),
  ),
  EqualizationModel(
    name: "Normal",
    values: List.generate(10, (index) => 50.0.toSignal()),
  ),
];

final selectedEqualization = Signal<EqualizationModel?>(null);
