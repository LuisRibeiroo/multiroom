import 'package:equatable/equatable.dart';

class InputModel extends Equatable {
  const InputModel({
    required this.name,
    required this.active,
  });

  final String name;
  final bool active;

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
