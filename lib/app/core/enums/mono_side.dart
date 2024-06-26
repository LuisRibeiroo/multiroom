import 'package:hive_flutter/hive_flutter.dart';

part 'mono_side.g.dart';

@HiveType(typeId: 9)
enum MonoSide {
  @HiveField(0)
  undefined,
  @HiveField(1)
  left,
  @HiveField(2)
  right;
}
