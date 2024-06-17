import 'package:equatable/equatable.dart';

class Frequency extends Equatable {
  const Frequency({
    required this.id,
    required this.name,
    required this.value,
  });

  factory Frequency.empty() {
    return const Frequency(
      id: 'B0',
      name: '',
      value: 0,
    );
  }

  factory Frequency.fromMap(Map<String, dynamic> map) {
    return Frequency(
      id: map["id"],
      name: map["name"],
      value: map["value"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "value": value,
    };
  }

  static List<Frequency> build([
    int v60 = 0,
    int v250 = 0,
    int v1k = 0,
    int v3k = 0,
    int v6k = 0,
    int v16k = 0,
  ]) =>
      [
        Frequency(id: "B1", name: "60", value: v60),
        Frequency(id: "B2", name: "250", value: v250),
        Frequency(id: "B3", name: "1k", value: v1k),
        Frequency(id: "B4", name: "3k", value: v3k),
        Frequency(id: "B5", name: "6k", value: v6k),
        Frequency(id: "B6", name: "16k", value: v16k),
      ];

  final String id;
  final String name;
  final int value;

  Frequency copyWith({
    String? name,
    int? value,
  }) {
    return Frequency(
      id: id,
      name: name ?? this.name,
      value: value ?? this.value,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        value,
      ];
}
