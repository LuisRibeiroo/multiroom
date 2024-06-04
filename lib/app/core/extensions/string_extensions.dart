extension StringExt on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;

  String or(String other) => isNullOrEmpty ? other : this!;

  String get numbersOnly =>
      isNullOrEmpty ? "" : this!.replaceAll(RegExp(r'[^0-9]'), '');

  String get toPhone {
    if (isNullOrEmpty) {
      return "";
    }

    if (this!.numbersOnly.length != 11) {
      return this!.numbersOnly;
    }

    return "(${this!.numbersOnly.substring(0, 2)}) ${this!.numbersOnly.substring(2, 7)}-${this!.numbersOnly.substring(7, 11)}";
  }
}
