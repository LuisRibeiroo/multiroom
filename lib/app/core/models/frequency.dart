import 'package:equatable/equatable.dart';

class Frequency extends Equatable {
  const Frequency({
    required this.name,
    required this.value,
  });

  factory Frequency.empty() {
    return const Frequency(
      name: '',
      value: 0,
    );
  }

  static List<Frequency> build([int value = 50]) => [
        Frequency(name: "32", value: value),
        Frequency(name: "64", value: value),
        Frequency(name: "125", value: value),
        Frequency(name: "250", value: value),
        Frequency(name: "500", value: value),
        Frequency(name: "1000", value: value),
        Frequency(name: "2000", value: value),
        Frequency(name: "4000", value: value),
      ];

  final String name;
  final int value;

  Frequency copyWith({
    String? name,
    int? value,
  }) {
    return Frequency(
      name: name ?? this.name,
      value: value ?? this.value,
    );
  }

  @override
  List<Object?> get props => [
        name,
        value,
      ];
}
