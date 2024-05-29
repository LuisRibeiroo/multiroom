import 'package:signals/signals_flutter.dart';

class EqualizationModel {
  const EqualizationModel({
    required this.name,
    required this.values,
  });

  final String name;
  final List<Signal<double>> values;

  EqualizationModel copyWith({
    String? name,
    List<Signal<double>>? values,
  }) {
    return EqualizationModel(
      name: name ?? this.name,
      values: values ?? this.values,
    );
  }
}
