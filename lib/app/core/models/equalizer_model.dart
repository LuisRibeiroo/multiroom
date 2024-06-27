import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

import 'frequency.dart';
import 'selectable_model.dart';

part 'equalizer_model.g.dart';

@HiveType(typeId: 2)
class EqualizerModel extends Equatable implements SelectableModel {
  const EqualizerModel({
    required this.name,
    required this.frequencies,
  });

  factory EqualizerModel.builder({
    required String name,
    int v60 = 0,
    int v250 = 0,
    int v1k = 0,
    int v3k = 0,
    int v6k = 0,
    int v16k = 0,
  }) =>
      EqualizerModel(
        name: name,
        frequencies: Frequency.build(
          v60,
          v250,
          v1k,
          v3k,
          v6k,
          v16k,
        ),
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

  @HiveField(0)
  final String name;
  @HiveField(1)
  final List<Frequency> frequencies;

  bool get isEmpty => this == EqualizerModel.empty();

  bool equalsFrequencies(EqualizerModel other) =>
      other.frequencies.mapIndexed((idx, f) => f.value == frequencies[idx].value).every((v) => v);

  @override
  String get label => name;

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
        name,
        frequencies,
      ];

  @override
  String toString() {
    return "$EqualizerModel($name, $frequencies)";
  }
}
