import 'package:equatable/equatable.dart';

import 'zone_model.dart';

class ZoneGroupModel extends Equatable {
  const ZoneGroupModel({
    required this.id,
    required this.name,
    required this.zones,
  });

  factory ZoneGroupModel.builder({
    required int index,
  }) {
    return ZoneGroupModel(
      id: "G$index",
      name: "Grupo $index",
      zones: const [],
    );
  }

  factory ZoneGroupModel.empty() {
    return const ZoneGroupModel(
      id: "G0",
      name: "",
      zones: [],
    );
  }

  factory ZoneGroupModel.fromMap(Map<String, dynamic> map) {
    return ZoneGroupModel(
      id: map['id'],
      name: map["name"],
      zones: List.from(map['zones']?.map((x) => ZoneModel.fromMap(x))),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'zones': zones.map((x) => x.toMap()).toList(),
    };
  }

  final String id;
  final String name;
  final List<ZoneModel> zones;

  ZoneGroupModel copyWith({
    String? name,
    List<ZoneModel>? zones,
  }) {
    return ZoneGroupModel(
      id: id,
      name: name ?? this.name,
      zones: zones ?? this.zones,
    );
  }

  bool get isEmpty => this == ZoneGroupModel.empty();

  @override
  List<Object?> get props => [
        id,
        name,
        zones,
      ];
}
