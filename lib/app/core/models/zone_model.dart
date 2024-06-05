import 'package:equatable/equatable.dart';
import 'package:multiroom/app/core/enums/zone_mode.dart';

import 'equalizer_model.dart';

class ZoneModel extends Equatable {
  const ZoneModel({
    required this.id,
    required this.name,
    required this.active,
    required this.mode,
    required this.volume,
    required this.balance,
    required this.equalizer,
  });

  factory ZoneModel.builder({required int index, required String name}) {
    return ZoneModel(
      id: "Z$index",
      name: name,
      active: true,
      mode: ZoneMode.stereo,
      volume: 50,
      balance: 0,
      equalizer: EqualizerModel.builder(name: "Custom", value: 10),
    );
  }

  factory ZoneModel.empty() {
    return ZoneModel(
      id: 'Z0',
      name: '',
      active: false,
      mode: ZoneMode.stereo,
      volume: 0,
      balance: 0,
      equalizer: EqualizerModel.empty(),
    );
  }

  final String id;
  final String name;
  final bool active;
  final ZoneMode mode;
  final int volume;
  final int balance;
  final EqualizerModel equalizer;

  bool get isEmpty => this == ZoneModel.empty();

  ZoneModel copyWith({
    String? name,
    bool? active,
    ZoneMode? mode,
    int? volume,
    int? balance,
    EqualizerModel? equalizer,
  }) {
    return ZoneModel(
      id: id,
      name: name ?? this.name,
      active: active ?? this.active,
      mode: mode ?? this.mode,
      volume: volume ?? this.volume,
      balance: balance ?? this.balance,
      equalizer: equalizer ?? this.equalizer,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        active,
        mode,
        volume,
        balance,
        equalizer,
      ];
}
