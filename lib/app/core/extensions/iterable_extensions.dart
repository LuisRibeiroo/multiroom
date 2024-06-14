extension IterableExt on Iterable? {
  bool get isNullOrEmpty => this == null || (this?.isEmpty ?? true);
  bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;

  
}
