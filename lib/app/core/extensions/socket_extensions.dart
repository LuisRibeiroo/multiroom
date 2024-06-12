import 'dart:io';

import 'package:logger/logger.dart';

final _logger = Logger(printer: SimplePrinter(printTime: true));

extension SocketExtensions on Socket {
  void writeLog(String data) {
    writeln(data);
    _logger.i(">>> $data");
  }
}
