import 'dart:io';

import 'package:logger/logger.dart';

final _logger = Logger(
    printer: SimplePrinter(
  printTime: true,
  colors: false,
));

extension SocketExtensions on Socket {
  void writeLog(String data) {
    writeln(data);
    _logger.i(">>> $data");
  }
}
