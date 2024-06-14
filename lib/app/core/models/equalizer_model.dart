import 'package:equatable/equatable.dart';

import 'frequency.dart';

class EqualizerModel extends Equatable {
  const EqualizerModel({
    required this.name,
    required this.frequencies,
  });

  factory EqualizerModel.builder({
    required String name,
    int value = 50,
  }) =>
      EqualizerModel(
        name: name,
        frequencies: Frequency.build(value),
      );

  factory EqualizerModel.custom({
    required List<Frequency> frequencies,
  }) =>
      EqualizerModel(
        name: "Custom",
        frequencies: frequencies,
      );

  factory EqualizerModel.empty() {
    return const EqualizerModel(
      name: '',
      frequencies: [],
    );
  }

  factory EqualizerModel.fromMap(Map<String, dynamic> map) {
    return EqualizerModel(
      name: map["name"],
      frequencies: List<Frequency>.from(map['frequencies']?.map((x) => Frequency.fromMap(x))),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "frequencies": frequencies.map((f) => f.toMap()).toList(),
    };
  }

  final String name;
  final List<Frequency> frequencies;

  bool get isEmpty => this == EqualizerModel.empty();

  EqualizerModel copyWith({
    String? name,
    List<Frequency>? frequencies,
  }) {
    return EqualizerModel(
      name: name ?? this.name,
      frequencies: frequencies ?? this.frequencies,
    );
  }

  @override
  List<Object?> get props => [
        frequencies,
      ];

  @override
  String toString() {
    return "$EqualizerModel($name, $frequencies)";
  }
}
