import 'package:equatable/equatable.dart';

class ZoneModel extends Equatable {
  const ZoneModel({
    required this.name,
    required this.active,
    required this.isStereo,
    required this.volume,
    required this.balance,
  });

  final String name;
  final bool active;
  final bool isStereo;
  final int volume;
  final int balance;

  ZoneModel copyWith({
    String? name,
    bool? active,
    bool? isStereo,
    int? volume,
    int? balance,
  }) {
    return ZoneModel(
      name: name ?? this.name,
      active: active ?? this.active,
      isStereo: isStereo ?? this.isStereo,
      volume: volume ?? this.volume,
      balance: balance ?? this.balance,
    );
  }

  @override
  List<Object?> get props => [
        name,
        active,
        isStereo,
        volume,
        balance,
      ];
}
