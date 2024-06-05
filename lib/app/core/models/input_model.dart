import 'package:equatable/equatable.dart';

class InputModel extends Equatable {
  const InputModel({
    required this.name,
    required this.active,
  });

  factory InputModel.empty() {
    return const InputModel(
      name: '',
      active: false,
    );
  }

  factory InputModel.builder({required String name}) {
    return InputModel(
      name: name,
      active: false,
    );
  }

  final String name;
  final bool active;

  bool get isEmpty => this == InputModel.empty();

  InputModel copyWith({
    String? name,
    bool? active,
  }) {
    return InputModel(
      name: name ?? this.name,
      active: active ?? this.active,
    );
  }

  @override
  List<Object?> get props => [
        name,
        active,
      ];
}
