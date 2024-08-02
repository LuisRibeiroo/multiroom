import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:multiroom/app/core/extensions/map_extensions.dart';

import 'selectable_model.dart';

part 'channel_model.g.dart';

@HiveType(typeId: 0)
class ChannelModel extends Equatable implements SelectableModel {
  const ChannelModel({
    required this.id,
    required this.name,
    required this.active,
  });

  const ChannelModel.empty() : this(id: "CH1", name: "", active: false);

  factory ChannelModel.builder({required int index, required String name}) {
    return ChannelModel(
      id: "CH$index",
      name: name,
      active: false,
    );
  }

  factory ChannelModel.fromMap(Map<String, dynamic>? map) {
    if (map.isNullOrEmpty) {
      return const ChannelModel.empty();
    }

    return ChannelModel(
      id: map!['id'],
      name: map['name'],
      active: map['active'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'active': active,
    };
  }

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final bool active;

  bool get isEmpty => this == const ChannelModel.empty();

  @override
  String get label => name;

  ChannelModel copyWith({
    String? name,
    bool? active,
  }) {
    return ChannelModel(
      id: id,
      name: name ?? this.name,
      active: active ?? this.active,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        active,
      ];
}
