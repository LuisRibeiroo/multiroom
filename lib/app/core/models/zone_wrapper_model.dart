import 'package:equatable/equatable.dart';

import '../enums/mono_side.dart';
import '../enums/zone_mode.dart';
import 'zone_model.dart';

typedef MonoZones = ({ZoneModel left, ZoneModel right});

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
  }) {
    return ZoneWrapperModel(
      id: "Z$index",
      mode: ZoneMode.stereo,
      stereoZone: ZoneModel.builder(id: "$index", name: name),
      monoZones: (
        left: ZoneModel.builder(
          id: "${index}L",
          name: "${name}L",
          side: MonoSide.left,
        ),
        right: ZoneModel.builder(
          id: "${index}R",
          name: "${name}R",
          side: MonoSide.right,
        ),
      ),
    );
  }

  factory ZoneWrapperModel.empty() {
    return ZoneWrapperModel(
      id: "Z0",
      mode: ZoneMode.stereo,
      stereoZone: ZoneModel.empty(),
      monoZones: (
        left: ZoneModel.empty(),
        right: ZoneModel.empty(),
      ),
    );
  }

  final String id;
  final ZoneMode mode;
  final ZoneModel stereoZone;
  final MonoZones monoZones;

  ZoneWrapperModel copyWith({
    ZoneMode? mode,
    ZoneModel? stereoZone,
    MonoZones? monoZones,
  }) {
    return ZoneWrapperModel(
      id: id,
      mode: mode ?? this.mode,
      stereoZone: stereoZone ?? this.stereoZone,
      monoZones: monoZones ?? this.monoZones,
    );
  }

  bool get isEmpty => this == ZoneWrapperModel.empty();
  bool get isStereo => mode == ZoneMode.stereo;
  List<ZoneModel> get zones => isStereo ? [stereoZone] : [monoZones.left, monoZones.right];

  @override
  List<Object?> get props => [
        id,
        mode,
        stereoZone,
        monoZones,
      ];
}
