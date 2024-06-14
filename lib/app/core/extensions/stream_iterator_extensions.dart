import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

final _logger = Logger(
    printer: SimplePrinter(
  printTime: true,
));

extension StreamIteratorExt on StreamIterator {
  Future<String> readSync({bool longResponse = false}) async {
    try {
      if (longResponse) {
        await Future.delayed(Durations.short1);
      }

      while (await moveNext() == false) {
        await Future.delayed(Durations.short1);
      }

      final response = String.fromCharCodes(current);
      _logger.i("<<< $response");

      return response;
    } catch (exception) {
      await cancel();
      throw Exception("Erro ao ler resposta [$exception]");
    }
  }
}
