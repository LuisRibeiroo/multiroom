import 'package:equatable/equatable.dart';

import 'selectable_model.dart';
import 'zone_model.dart';

class ZoneGroupModel extends Equatable implements SelectableModel {
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

  bool get isEmpty => id == ZoneGroupModel.empty().id;
  bool get hasZones => zones.isNotEmpty;

  @override
  String get label => name;
  @override
  String get secondary => zones.map((z) => z.name).join(", ");

  @override
  List<Object?> get props => [
        id,
        name,
        zones,
      ];
}
