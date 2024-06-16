import 'package:equatable/equatable.dart';

import 'selectable_model.dart';

class ChannelModel extends Equatable implements SelectableModel {
  const ChannelModel({
    required this.id,
    required this.name,
    required this.active,
  });

  factory ChannelModel.empty() {
    return const ChannelModel(
      id: "CH1",
      name: "",
      active: false,
    );
  }

  factory ChannelModel.builder({required int index, required String name}) {
    return ChannelModel(
      id: "CH$index",
      name: name,
      active: false,
    );
  }

  factory ChannelModel.fromMap(Map<String, dynamic> map) {
    return ChannelModel(
      id: map['id'],
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

  final String id;
  final String name;
  final bool active;

  bool get isEmpty => this == ChannelModel.empty();

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
