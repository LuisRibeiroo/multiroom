import 'package:equatable/equatable.dart';
import 'package:multiroom/app/core/enums/zone_mode.dart';
import 'package:multiroom/app/core/models/channel_model.dart';

import 'equalizer_model.dart';

class ZoneModel extends Equatable {
  const ZoneModel({
    required this.id,
    required this.name,
    required this.active,
    required this.channels,
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
      channels: List.generate(
        8,
        (idx) => ChannelModel.builder(index: idx + 1, name: "Input ${idx + 1}"),
      ),
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
      channels: const [],
      mode: ZoneMode.stereo,
      volume: 0,
      balance: 0,
      equalizer: EqualizerModel.empty(),
    );
  }

  final String id;
  final String name;
  final bool active;
  final List<ChannelModel> channels;
  final ZoneMode mode;
  final int volume;
  final int balance;
  final EqualizerModel equalizer;

  bool get isEmpty => this == ZoneModel.empty();

  ZoneModel copyWith({
    String? name,
    bool? active,
    List<ChannelModel>? channels,
    ZoneMode? mode,
    int? volume,
    int? balance,
    EqualizerModel? equalizer,
  }) {
    return ZoneModel(
      id: id,
      name: name ?? this.name,
      active: active ?? this.active,
      channels: channels ?? this.channels,
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
        channels,
        mode,
        volume,
        balance,
        equalizer,
      ];
}
