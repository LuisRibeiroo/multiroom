import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:multiroom/app/core/models/zone_group_model.dart';

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
    required this.volume,
    required this.balance,
    required this.equalizer,
    required this.wrapperId,
    this.side = MonoSide.undefined,
    this.channel = const ChannelModel.empty(),
    this.groupId = "",
    this.maxVolumeLeft = 100,
    this.maxVolumeRight = 100,
    this.deviceSerial = "",
    this.macAddress = "",
  });

  factory ZoneModel.builder({
    required String id,
    required String name,
    required String wrapperId,
    required String deviceSerial,
    required String macAddress,
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
      volume: 50,
      balance: 50,
      equalizer: EqualizerModel.builder(name: "Custom"),
      side: side,
      channel: ChannelModel.builder(index: 1, name: "Input 1"),
      deviceSerial: deviceSerial,
      macAddress: macAddress,
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
      equalizer: EqualizerModel.empty(),
      channel: const ChannelModel.empty(),
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
      balance: map['balance'],
      equalizer: EqualizerModel.fromMap(map['equalizer']),
      side: MonoSide.values[map['side']],
      channel: map['channel'] != null ? ChannelModel.fromMap(map['channel']) : const ChannelModel.empty(),
      groupId: map['groupId'],
      maxVolumeLeft: map['maxVolumeLeft'],
      maxVolumeRight: map['maxVolumeRight'],
      deviceSerial: map["deviceSerial"],
      macAddress: map["macAddress"],
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
      'balance': balance,
      'equalizer': equalizer.toMap(),
      'side': side.index,
      'channel': channel.toMap(),
      'groupId': groupId,
      'maxVolumeLeft': maxVolumeLeft,
      'maxVolumeRight': maxVolumeRight,
      'deviceSerial': deviceSerial,
      'macAddress': macAddress,
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
  @HiveField(11, defaultValue: ChannelModel.empty())
  final ChannelModel channel;
  @HiveField(12, defaultValue: "")
  final String groupId;
  @HiveField(13, defaultValue: 100)
  final int maxVolumeLeft;
  @HiveField(14, defaultValue: 100)
  final int maxVolumeRight;
  @HiveField(15, defaultValue: "")
  final String deviceSerial;
  @HiveField(16, defaultValue: "")
  final String macAddress;

  bool get isEmpty => id == ZoneModel.empty().id;
  bool get isStereo => side == MonoSide.undefined;
  int get maxVolume => isStereo || side == MonoSide.right ? maxVolumeRight : maxVolumeLeft;

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
    bool? isGroup,
    ChannelModel? channel,
    String? groupId,
    int? maxVolumeLeft,
    int? maxVolumeRight,
    String? deviceSerial,
    String? macAddress,
  }) {
    return ZoneModel(
      id: id,
      wrapperId: wrapperId,
      name: name ?? this.name,
      active: active ?? this.active,
      channels: channels ?? this.channels,
      volume: volume ?? this.volume,
      balance: balance ?? this.balance,
      equalizer: equalizer ?? this.equalizer,
      side: side ?? this.side,
      channel: channel ?? this.channel,
      groupId: groupId ?? this.groupId,
      maxVolumeLeft: maxVolumeLeft ?? this.maxVolumeLeft,
      maxVolumeRight: maxVolumeRight ?? this.maxVolumeRight,
      deviceSerial: deviceSerial ?? this.deviceSerial,
      macAddress: macAddress ?? this.macAddress,
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
        balance,
        equalizer,
        side,
        channel,
        groupId,
        maxVolumeLeft,
        maxVolumeRight,
        deviceSerial,
        macAddress,
      ];
}

extension ZoneListExt on List<ZoneModel> {
  ZoneModel? getZoneById(String id) {
    return firstWhereOrNull((z) => z.id == id);
  }

  bool containsZone(ZoneModel zone) {
    return any((z) => z.id == zone.id);
  }

  List<ZoneModel> grouped(List<ZoneGroupModel> groups) {
    final temp = where((zone) => groups.map((g) => g.zones.containsZone(zone)).every((v) => !v)).toList();

    for (final g in groups) {
      if (g.hasZones) {
        if (temp.where((z) => z.id == g.asZone.id).isEmpty) {
          temp.add(g.asZone);
        }
      }
    }

    return temp..sort((a, b) => a.id.compareTo(b.id));
  }
}
