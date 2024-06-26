import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

import '../enums/mono_side.dart';
import 'zone_model.dart';

part 'mono_zones.g.dart';

@HiveType(typeId: 11)
class MonoZones extends Equatable {
  const MonoZones({
    required this.left,
    required this.right,
  });

  factory MonoZones.empty() {
    return MonoZones(
      left: ZoneModel.empty(),
      right: ZoneModel.empty(),
    );
  }

  factory MonoZones.builder({
    required String id,
    required String name,
  }) {
    return MonoZones(
      left: ZoneModel.builder(
        id: "${id}L",
        name: "${name}L",
        side: MonoSide.left,
      ),
      right: ZoneModel.builder(
        id: "${id}R",
        name: "${name}R",
        side: MonoSide.right,
      ),
    );
  }

  factory MonoZones.fromMap(Map<String, dynamic> map) {
    return MonoZones(
      left: ZoneModel.fromMap(map['left']),
      right: ZoneModel.fromMap(map['right']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'left': left.toMap(),
      'right': right.toMap(),
    };
  }

  @HiveField(0)
  final ZoneModel left;
  @HiveField(1)
  final ZoneModel right;

  MonoZones copyWith({
    ZoneModel? left,
    ZoneModel? right,
  }) {
    return MonoZones(
      left: left ?? this.left,
      right: right ?? this.right,
    );
  }

  @override
  List<Object?> get props => [
        left,
        right,
      ];
}
