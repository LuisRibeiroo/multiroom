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

  factory EqualizerModel.empty() {
    return const EqualizerModel(
      name: '',
      frequencies: [],
    );
  }

  final String name;
  final List<Frequency> frequencies;

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
}
