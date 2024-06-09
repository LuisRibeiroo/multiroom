extension ListExt<E> on List<E>? {
  bool get isNullOrEmpty => this == null || (this?.isEmpty ?? true);
  bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;

  void addIfAbsent(E item) {
    if (this == null) {
      return;
    }

    if (this!.contains(item) == false) {
      this!.add(item);
    }
  }

  void addOrReplace(E item) {
    if (this == null) {
      return;
    }

    if (this!.contains(item) == false) {
      this!.add(item);
    } else {
      final idx = this!.indexOf(item);
      this!.remove(item);
      this!.insert(idx, item);
    }
  }

  void replaceWhere(bool Function(E) test, E element) {
    if (this == null) {
      return;
    }

    for (E element in this!) {
      if (test(element)) {
        final idx = this!.indexOf(element);
        this!.remove(element);
        this!.insert(idx, element);
      }
    }
  }
}
