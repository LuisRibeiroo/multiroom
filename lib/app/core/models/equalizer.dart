import 'package:equatable/equatable.dart';

class Equalizer extends Equatable {
  const Equalizer({
    required this.name,
    required this.value,
  });

  final String name;
  final int value;

  @override
  List<Object?> get props => [
        name,
        value,
      ];
}
