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
    // Future.value(() => write("$data\r\n")).timeout(
    //   const Duration(seconds: readTimeout),
    //   onTimeout: () => throw TimeoutException("App timeout"),
    // );

    write("$data\r\n");
    _logger.i("[DBG] >>> $data");
  }

  void listenString({
    required void Function(String) onData,
    void Function(String)? onError,
  }) {
    try {
      listen(
        (data) {
          final decoded = String.fromCharCodes(data);
          final clean = decoded.replaceAll("\r", "");
          _logger.i("[DBG] <<< $clean");

          if (clean.toUpperCase().contains("ERROR") && clean.contains("zone_mode_error") == false) {
            onError?.call(clean);
            return;
          }

          onData(clean);
        },
        onError: (e) {
          onError?.call(e.toString());
        },
      );
    } on StateError catch (exception) {
      if (exception.message != 'Stream has already been listened to.') {
        rethrow;
      }
    }
  }
}
