import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'frequency.g.dart';

@HiveType(typeId: 3)
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

  factory Frequency.fromValue({
    required String id,
    required String value,
  }) {
    return Frequency(
      id: id,
      name: _bands[id] ?? "",
      value: int.tryParse(value) ?? 0,
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
    int b1 = 0,
    int b2 = 0,
    int b3 = 0,
    int b4 = 0,
    int b5 = 0,
    int b6 = 0,
  ]) =>
      [
        Frequency(id: "B1", name: _bands["B1"]!, value: b1),
        Frequency(id: "B2", name: _bands["B2"]!, value: b2),
        Frequency(id: "B3", name: _bands["B3"]!, value: b3),
        Frequency(id: "B4", name: _bands["B4"]!, value: b4),
        Frequency(id: "B5", name: _bands["B5"]!, value: b5),
        Frequency(id: "B6", name: _bands["B6"]!, value: b6),
      ];

  static List<Frequency> buildFromList(List<int> list) => [
        Frequency(id: "B1", name: _bands["B1"]!, value: list[0]),
        Frequency(id: "B2", name: _bands["B2"]!, value: list[1]),
        Frequency(id: "B3", name: _bands["B3"]!, value: list[2]),
        Frequency(id: "B4", name: _bands["B4"]!, value: list[3]),
        Frequency(id: "B5", name: _bands["B5"]!, value: list[4]),
        Frequency(id: "B6", name: _bands["B6"]!, value: list[5]),
      ];

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
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

  static const _bands = {
    "B1": "60",
    "B2": "250",
    "B3": "1k",
    "B4": "3k",
    "B5": "6k",
    "B6": "16k",
  };

  @override
  List<Object?> get props => [
        id,
        name,
        value,
      ];
}
