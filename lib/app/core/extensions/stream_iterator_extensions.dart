import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../utils/constants.dart';

final _logger = Logger(
    printer: SimplePrinter(
  printTime: true,
  colors: false,
));

extension StreamIteratorExt on StreamIterator {
  Future<String> readSync({bool longResponse = false}) async {
    try {
      if (longResponse) {
        await Future.delayed(Durations.short3);
      }

      while (await moveNext().timeout(
            const Duration(seconds: readTimeout),
            onTimeout: () => throw TimeoutException("App timeout"),
          ) ==
          false) {
        await Future.delayed(Durations.short1);
      }

      final response = String.fromCharCodes(current);
      _logger.i("[DBG] <<< $response");

      return response;
    } catch (exception) {
      await cancel();
      throw Exception("Erro ao ler resposta [$exception]");
    }
  }
}
