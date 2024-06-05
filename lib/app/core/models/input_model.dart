import 'package:equatable/equatable.dart';

class InputModel extends Equatable {
  const InputModel({
    required this.id,
    required this.name,
    required this.active,
  });

  factory InputModel.empty() {
    return const InputModel(
      id: 'CH0',
      name: '',
      active: false,
    );
  }

  factory InputModel.builder({required int index, required String name}) {
    return InputModel(
      id: "CH$index",
      name: name,
      active: false,
    );
  }

  final String id;
  final String name;
  final bool active;

  bool get isEmpty => this == InputModel.empty();

  InputModel copyWith({
    String? name,
    bool? active,
  }) {
    return InputModel(
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
