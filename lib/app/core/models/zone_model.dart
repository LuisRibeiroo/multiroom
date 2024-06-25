import 'package:equatable/equatable.dart';
import 'selectable_model.dart';

import '../enums/mono_side.dart';
import 'channel_model.dart';
import 'equalizer_model.dart';

class ZoneModel extends Equatable implements SelectableModel {
  const ZoneModel({
    required this.id,
    required this.name,
    required this.active,
    required this.channels,
    required this.volume,
    required this.balance,
    required this.equalizer,
    this.side = MonoSide.undefined,
  });

  factory ZoneModel.builder({
    required String id,
    required String name,
    MonoSide side = MonoSide.undefined,
  }) {
    return ZoneModel(
      id: "Z$id",
      name: name,
      active: true,
      channels: List.generate(
        8,
        (idx) => ChannelModel.builder(index: idx + 1, name: "Input ${idx + 1}"),
      ),
      volume: 50,
      balance: 50,
      equalizer: EqualizerModel.builder(name: "Custom"),
      side: side,
    );
  }

  factory ZoneModel.empty() {
    return ZoneModel(
      id: 'Z0',
      name: '',
      active: false,
      channels: const [],
      volume: 0,
      balance: 0,
      equalizer: EqualizerModel.empty(),
    );
  }

  factory ZoneModel.fromMap(Map<String, dynamic> map) {
    return ZoneModel(
      id: map['id'],
      name: map['name'],
      active: map['active'],
      channels: List<ChannelModel>.from(map['channels']?.map((x) => ChannelModel.fromMap(x))),
      volume: map['volume'],
      balance: map['balance'],
      equalizer: EqualizerModel.fromMap(map['equalizer']),
      side: MonoSide.values[map['side']],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'active': active,
      'channels': channels.map((x) => x.toMap()).toList(),
      'volume': volume,
      'balance': balance,
      'equalizer': equalizer.toMap(),
      'side': side.index,
    };
  }

  final String id;
  final String name;
  final bool active;
  final List<ChannelModel> channels;
  final int volume;
  final int balance;
  final EqualizerModel equalizer;
  final MonoSide side;

  bool get isEmpty => id == ZoneModel.empty().id;
  bool get isStereo => side == MonoSide.undefined;

  @override
  String get label => name;

  ZoneModel copyWith({
    String? name,
    bool? active,
    List<ChannelModel>? channels,
    int? volume,
    int? balance,
    EqualizerModel? equalizer,
    MonoSide? side,
  }) {
    return ZoneModel(
      id: id,
      name: name ?? this.name,
      active: active ?? this.active,
      channels: channels ?? this.channels,
      volume: volume ?? this.volume,
      balance: balance ?? this.balance,
      equalizer: equalizer ?? this.equalizer,
      side: side ?? this.side,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        active,
        channels,
        volume,
        balance,
        equalizer,
        side,
      ];
}
