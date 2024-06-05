import 'package:equatable/equatable.dart';

import 'equalizer_model.dart';

class ZoneModel extends Equatable {
  const ZoneModel({
    required this.name,
    required this.active,
    required this.isStereo,
    required this.volume,
    required this.balance,
    required this.equalizer,
  });

  factory ZoneModel.builder({required String name}) {
    return ZoneModel(
      name: name,
      active: true,
      isStereo: true,
      volume: 50,
      balance: 0,
      equalizer: EqualizerModel.builder(name: "Custom"),
    );
  }

  factory ZoneModel.empty() {
    return ZoneModel(
      name: '',
      active: false,
      isStereo: false,
      volume: 0,
      balance: 0,
      equalizer: EqualizerModel.empty(),
    );
  }

  final String name;
  final bool active;
  final bool isStereo;
  final int volume;
  final int balance;
  final EqualizerModel equalizer;

  bool get isEmpty => this == ZoneModel.empty();

  ZoneModel copyWith({
    String? name,
    bool? active,
    bool? isStereo,
    int? volume,
    int? balance,
    EqualizerModel? equalizer,
  }) {
    return ZoneModel(
      name: name ?? this.name,
      active: active ?? this.active,
      isStereo: isStereo ?? this.isStereo,
      volume: volume ?? this.volume,
      balance: balance ?? this.balance,
      equalizer: equalizer ?? this.equalizer,
    );
  }

  @override
  List<Object?> get props => [
        name,
        active,
        isStereo,
        volume,
        balance,
        equalizer,
      ];
}
