import 'package:hive/hive.dart';

import '../extensions/string_extensions.dart';

part 'device_type.g.dart';

@HiveType(typeId: 8)
enum DeviceType {
  @HiveField(0)
  master,
  @HiveField(1)
  slave;

  static fromString(String value) => switch (value.toLowerCase().lettersOnly) {
        "master" => master,
        "slave" => slave,
        _ => master,
      };
}
