import 'dart:io';

import 'package:logger/logger.dart';

final _logger = Logger(
    printer: SimplePrinter(
  printTime: true,
  colors: false,
));

extension SocketExtensions on Socket {
  void writeLog(String data) {
    // Do not remove \r\n, they're line terminators for Multiroom
    write("$data\r\n");
    _logger.i("[DBG] >>> $data");
  }

  void listenString({
    required void Function(String) onData,
    void Function(String)? onError,
  }) {
    listen((data) {
      final decoded = String.fromCharCodes(data);
      final clean = decoded.replaceAll("\r", "");
      _logger.i("[DBG] <<< $clean");

      if (clean.toUpperCase().contains("ERROR")) {
        onError?.call(clean);
        return;
      }

      onData(clean);
    });
  }
}
