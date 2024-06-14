import 'package:multiroom/app/core/extensions/string_extensions.dart';

enum DeviceType {
  master,
  slave;

  static fromString(String value) => switch (value.toLowerCase().lettersOnly) {
        "master" => master,
        "slave" => slave,
        _ => master,
      };
}
