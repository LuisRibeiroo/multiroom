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
      String buff = "";

      listen(
        (data) {
          final decoded = String.fromCharCodes(data);
          final clean = decoded.replaceAll("\r", "");

          _logger.i("[DBG] <<< $clean");

          final lfRegex = RegExp(r"(\r\n|\r|\n)", dotAll: true);

          if (lfRegex.hasMatch(clean) && clean.endsWith("\n")) {
            buff += clean;
          } else {
            buff = clean;
            return;
          }

          if (buff.toUpperCase().contains("ERROR") && buff.contains("zone_mode_error") == false) {
            onError?.call(buff);
            return;
          }

          onData(buff);
          buff = "";
        },
        onError: (e) {
          onError?.call(e.toString());
        },
      );
    } catch (exception) {
      if (exception.toString().contains('Stream has already been listened to.') == false) {
        rethrow;
      }
    }
  }
}
