import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../enums/mono_side.dart';
import '../enums/zone_mode.dart';
import 'mono_zones.dart';
import 'zone_model.dart';

part 'zone_wrapper_model.g.dart';

@HiveType(typeId: 7)
class ZoneWrapperModel extends Equatable {
  const ZoneWrapperModel({
    required this.id,
    required this.mode,
    required this.stereoZone,
    required this.monoZones,
  });

  factory ZoneWrapperModel.builder({
    required int index,
    required String name,
    required String deviceSerial,
    required String macAddress,
    ZoneMode mode = ZoneMode.stereo,
  }) {
    return ZoneWrapperModel(
      id: "ZW$index",
      mode: mode,
      stereoZone: ZoneModel.builder(
        id: "$index",
        wrapperId: "ZW$index",
        name: name,
        deviceSerial: deviceSerial,
        macAddress: macAddress,
      ),
      monoZones: MonoZones.builder(
        id: "$index",
        wrapperId: "ZW$index",
        name: name,
        deviceSerial: deviceSerial,
        macAddress: macAddress,
      ),
    );
  }

  factory ZoneWrapperModel.empty() {
    return ZoneWrapperModel(
      id: "ZW0",
      mode: ZoneMode.stereo,
      stereoZone: ZoneModel.empty(),
      monoZones: MonoZones.empty(),
    );
  }

  factory ZoneWrapperModel.fromMap(Map<String, dynamic> map) {
    return ZoneWrapperModel(
      id: map['id'],
      mode: ZoneMode.values[map['mode']],
      stereoZone: ZoneModel.fromMap(map['stereoZone']),
      monoZones: MonoZones.fromMap(map['monoZones']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mode': mode.index,
      'stereoZone': stereoZone.toMap(),
      'monoZones': {
        'left': monoZones.left.toMap(),
        'right': monoZones.right.toMap(),
      },
    };
  }

  @HiveField(0)
  final String id;
  @HiveField(1)
  final ZoneMode mode;
  @HiveField(2)
  final ZoneModel stereoZone;
  @HiveField(3)
  final MonoZones monoZones;

  ZoneWrapperModel copyWith({
    ZoneMode? mode,
    ZoneModel? zone,
    MonoZones? monoZones,
  }) {
    if (isStereo) {
      return ZoneWrapperModel(
        id: id,
        mode: mode ?? this.mode,
        stereoZone: zone ?? stereoZone,
        monoZones: monoZones ?? this.monoZones,
      );
    } else {
      if (zone == null) {
        return ZoneWrapperModel(
          id: id,
          mode: mode ?? this.mode,
          stereoZone: stereoZone,
          monoZones: monoZones ?? this.monoZones,
        );
      }

      if (zone.side == MonoSide.left) {
        return ZoneWrapperModel(
          id: id,
          mode: mode ?? this.mode,
          stereoZone: stereoZone,
          monoZones: this.monoZones.copyWith(left: zone),
        );
      }

      if (zone.side == MonoSide.right) {
        return ZoneWrapperModel(
          id: id,
          mode: mode ?? this.mode,
          stereoZone: stereoZone,
          monoZones: this.monoZones.copyWith(right: zone),
        );
      }

      return ZoneWrapperModel(
        id: id,
        mode: mode ?? this.mode,
        stereoZone: stereoZone,
        monoZones: this.monoZones,
      );
    }
  }

  bool get isEmpty => this == ZoneWrapperModel.empty();
  bool get isStereo => mode == ZoneMode.stereo;
  List<ZoneModel> get zones => isStereo ? [stereoZone] : [monoZones.left, monoZones.right];

  int get maxVolumeRight => isStereo ? stereoZone.maxVolumeRight : monoZones.right.maxVolumeRight;
  int get maxVolumeLeft => isStereo ? stereoZone.maxVolumeLeft : monoZones.left.maxVolumeLeft;

  @override
  List<Object?> get props => [
        id,
        mode,
        stereoZone,
        monoZones,
      ];
}
