import 'package:equatable/equatable.dart';

class ChannelModel extends Equatable {
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

  final String id;
  final String name;
  final bool active;

  bool get isEmpty => this == ChannelModel.empty();

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

  @override
  bool? get stringify => false;
}
