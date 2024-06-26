import 'package:hive/hive.dart';

part 'zone_mode.g.dart';

@HiveType(typeId: 10)
enum ZoneMode {
  @HiveField(0)
  stereo,
  @HiveField(1)
  mono;
}
