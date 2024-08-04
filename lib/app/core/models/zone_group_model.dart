import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'selectable_model.dart';
import 'zone_model.dart';

part 'zone_group_model.g.dart';

@HiveType(typeId: 5)
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

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
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
  ZoneModel get asZone => hasZones
      ? zones.first.copyWith(
          name: name,
          isGroup: true,
          groupId: id,
          
        )
      : ZoneModel.empty();

  ZoneModel getZone(String id) {
    return zones.firstWhere(
      (z) => z.id == id,
      orElse: () => ZoneModel.empty(),
    );
  }

  @override
  String get label => name;

  @override
  List<Object?> get props => [
        id,
        name,
        zones,
      ];
}
