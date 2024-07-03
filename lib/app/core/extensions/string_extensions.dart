import 'dart:convert';

import 'package:crypto/crypto.dart';

extension StringExt on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;

  String or(String other) => isNullOrEmpty ? other : this!;

  String get numbersOnly => isNullOrEmpty ? "" : this!.replaceAll(RegExp(r'[^0-9]'), '');
  String get lettersOnly => isNullOrEmpty ? "" : this!.replaceAll(RegExp(r'[^a-zA-Z]'), '');
  String get removeSpecialChars => isNullOrEmpty ? "" : this!.replaceAll(RegExp(r"[\r\n\t]"), "");

  String get capitalize {
    if (isNullOrEmpty) {
      return "";
    }

    if (this!.length == 1) {
      return this!.toUpperCase();
    }

    return "${this![0].toUpperCase()}${this!.substring(1)}";
  }

  String get toPhone {
    if (isNullOrEmpty) {
      return "";
    }

    if (this!.numbersOnly.length != 11) {
      return this!.numbersOnly;
    }

    return "(${this!.numbersOnly.substring(0, 2)}) ${this!.numbersOnly.substring(2, 7)}-${this!.numbersOnly.substring(7, 11)}";
  }

  String get getMd5 {
    if (this == null) {
      return "";
    }

    return md5.convert(utf8.encode(this!)).toString();
  }

  String get toProjectId {
    if (this == null) {
      return "";
    }

    return "MR-${getMd5.substring(0, 8).toUpperCase()}";
  }
}
