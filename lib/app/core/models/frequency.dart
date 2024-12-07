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
    int v60 = 0,
    int v250 = 0,
    int v1k = 0,
    int v3k = 0,
    int v6k = 0,
    int v16k = 0,
  ]) =>
      [
        Frequency(id: "B1", name: _bands["B1"]!, value: v60),
        Frequency(id: "B2", name: _bands["B2"]!, value: v250),
        Frequency(id: "B3", name: _bands["B3"]!, value: v1k),
        Frequency(id: "B4", name: _bands["B4"]!, value: v3k),
        Frequency(id: "B5", name: _bands["B5"]!, value: v6k),
        Frequency(id: "B6", name: _bands["B6"]!, value: v16k),
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
