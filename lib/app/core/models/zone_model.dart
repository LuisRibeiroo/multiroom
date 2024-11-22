import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../enums/mono_side.dart';
import '../extensions/list_extensions.dart';
import 'channel_model.dart';
import 'equalizer_model.dart';
import 'selectable_model.dart';
import 'zone_group_model.dart';

part 'zone_model.g.dart';

@HiveType(typeId: 6)
class ZoneModel extends Equatable implements SelectableModel {
  const ZoneModel({
    required this.id,
    required this.name,
    required this.active,
    required this.volume,
    required this.balance,
    required this.equalizer,
    required this.wrapperId,
    required this.visible,
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
      volume: 50,
      balance: 50,
      equalizer: EqualizerModel.builder(name: "Custom"),
      side: side,
      channel: ChannelModel.builder(index: 1, name: "Input 1"),
      deviceSerial: deviceSerial,
      macAddress: macAddress,
      visible: true,
    );
  }

  factory ZoneModel.empty() {
    return ZoneModel(
      id: 'Z0',
      wrapperId: '',
      name: '',
      active: false,
      volume: 0,
      balance: 0,
      equalizer: EqualizerModel.empty(),
      visible: false,
    );
  }

  factory ZoneModel.fromMap(Map<String, dynamic> map) {
    return ZoneModel(
      id: map['id'],
      wrapperId: map['wrapperId'],
      name: map['name'],
      active: map['active'],
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
      visible: map['visible'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'wrapperId': wrapperId,
      'name': name,
      'active': active,
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
      'visible': visible,
    };
  }

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final bool active;
  @HiveField(3)
  final int volume;
  @HiveField(4)
  final int balance;
  @HiveField(5)
  final EqualizerModel equalizer;
  @HiveField(6)
  final MonoSide side;
  @HiveField(7, defaultValue: "")
  final String wrapperId;
  @HiveField(8)
  final ChannelModel channel;
  @HiveField(9, defaultValue: "")
  final String groupId;
  @HiveField(10, defaultValue: 100)
  final int maxVolumeLeft;
  @HiveField(11, defaultValue: 100)
  final int maxVolumeRight;
  @HiveField(12, defaultValue: "")
  final String deviceSerial;
  @HiveField(13, defaultValue: "")
  final String macAddress;
  @HiveField(14)
  final bool visible;

  bool get isEmpty => id == ZoneModel.empty().id;
  bool get isStereo => side == MonoSide.undefined;
  int get maxVolume => isStereo || side == MonoSide.right ? maxVolumeRight : maxVolumeLeft;

  @override
  String get label => name;

  ZoneModel copyWith({
    String? name,
    bool? active,
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
    bool? visible,
  }) {
    return ZoneModel(
      id: id,
      wrapperId: wrapperId,
      name: name ?? this.name,
      active: active ?? this.active,
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
      visible: visible ?? this.visible,
    );
  }

  @override
  List<Object?> get props => [
        id,
        wrapperId,
        name,
        active,
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
        visible,
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
    final newZones = where((zone) => groups.map((g) => g.zones.containsZone(zone)).every((v) => !v)).toList();

    for (final g in groups) {
      if (g.hasZones) {
        if (newZones.where((z) => z.id == g.asZone.id).isEmpty) {
          final currentZone = firstWhere((z) => z.id == g.asZone.id);
          final updatedGroup = g.copyWith(zones: g.zones.withReplacement((z) => z.id == currentZone.id, currentZone));

          newZones.add(updatedGroup.asZone);
        }
      }
    }

    return newZones..sort((a, b) => a.id.compareTo(b.id));
  }
}
