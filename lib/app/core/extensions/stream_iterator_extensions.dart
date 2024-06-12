import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

final _logger = Logger(
    printer: SimplePrinter(
  printTime: true,
));

extension StreamIteratorExt on StreamIterator {
  Future<String> readSync() async {
    try {
      while (await moveNext() == false) {
        await Future.delayed(Durations.short1);
      }

      final response = String.fromCharCodes(current);
      _logger.i("<<< $response");

      await cancel();

      return response;
    } catch (exception) {
      throw Exception("Erro ao ler resposta [$exception]");
    }
  }
}
