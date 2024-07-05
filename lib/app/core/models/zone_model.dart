import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../enums/mono_side.dart';
import 'channel_model.dart';
import 'equalizer_model.dart';
import 'selectable_model.dart';

part 'zone_model.g.dart';

@HiveType(typeId: 6)
class ZoneModel extends Equatable implements SelectableModel {
  const ZoneModel({
    required this.id,
    required this.name,
    required this.active,
    required this.channels,
    required this.maxVolume,
    required this.volume,
    required this.balance,
    required this.equalizer,
    required this.wrapperId,
    this.side = MonoSide.undefined,
    this.isGroup = false,
  });

  factory ZoneModel.builder({
    required String id,
    required String name,
    required String wrapperId,
    MonoSide side = MonoSide.undefined,
  }) {
    return ZoneModel(
      id: "Z$id",
      wrapperId: wrapperId,
      name: name,
      active: true,
      channels: List.generate(
        8,
        (idx) => ChannelModel.builder(index: idx + 1, name: "Input ${idx + 1}"),
      ),
      maxVolume: 100,
      volume: 50,
      balance: 50,
      equalizer: EqualizerModel.builder(name: "Custom"),
      side: side,
      isGroup: false,
    );
  }

  factory ZoneModel.empty() {
    return ZoneModel(
      id: 'Z0',
      wrapperId: '',
      name: '',
      active: false,
      channels: const [],
      volume: 0,
      balance: 0,
      maxVolume: 0,
      equalizer: EqualizerModel.empty(),
    );
  }

  factory ZoneModel.fromMap(Map<String, dynamic> map) {
    return ZoneModel(
      id: map['id'],
      wrapperId: map['wrapperId'],
      name: map['name'],
      active: map['active'],
      channels: List<ChannelModel>.from(map['channels']?.map((x) => ChannelModel.fromMap(x))),
      volume: map['volume'],
      maxVolume: map['maxVolume'],
      balance: map['balance'],
      equalizer: EqualizerModel.fromMap(map['equalizer']),
      side: MonoSide.values[map['side']],
      isGroup: map['isGroup'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'wrapperId': wrapperId,
      'name': name,
      'active': active,
      'channels': channels.map((x) => x.toMap()).toList(),
      'volume': volume,
      'maxVolume': maxVolume,
      'balance': balance,
      'equalizer': equalizer.toMap(),
      'side': side.index,
      'isGroup': isGroup,
    };
  }

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final bool active;
  @HiveField(3)
  final List<ChannelModel> channels;
  @HiveField(4)
  final int maxVolume;
  @HiveField(5)
  final int volume;
  @HiveField(6)
  final int balance;
  @HiveField(7)
  final EqualizerModel equalizer;
  @HiveField(8)
  final MonoSide side;
  @HiveField(9, defaultValue: "")
  final String wrapperId;
  @HiveField(10, defaultValue: false)
  final bool isGroup;

  bool get isEmpty => id == ZoneModel.empty().id;
  bool get isStereo => side == MonoSide.undefined;

  @override
  String get label => name;

  ZoneModel copyWith({
    String? name,
    bool? active,
    List<ChannelModel>? channels,
    int? volume,
    int? maxVolume,
    int? balance,
    EqualizerModel? equalizer,
    MonoSide? side,
    bool? isGroup,
  }) {
    return ZoneModel(
      id: id,
      wrapperId: wrapperId,
      name: name ?? this.name,
      active: active ?? this.active,
      channels: channels ?? this.channels,
      volume: volume ?? this.volume,
      maxVolume: maxVolume ?? this.maxVolume,
      balance: balance ?? this.balance,
      equalizer: equalizer ?? this.equalizer,
      side: side ?? this.side,
      isGroup: isGroup ?? this.isGroup,
    );
  }

  @override
  List<Object?> get props => [
        id,
        wrapperId,
        name,
        active,
        channels,
        volume,
        maxVolume,
        balance,
        equalizer,
        side,
        isGroup,
      ];
}
