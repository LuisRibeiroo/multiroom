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

    for (E e in this!) {
      if (test(e)) {
        final idx = this!.indexOf(e);
        this!.remove(e);
        this!.insert(idx, element);
      }
    }
  }

  List<E> withReplacement(bool Function(E) test, E element) {
    if (this == null) {
      return [element];
    }

    List<E> list = List<E>.from(this!);

    for (E e in list) {
      if (test(e)) {
        final idx = list.indexOf(e);
        list.remove(e);
        list.insert(idx, element);
      }
    }

    return list;
  }
}
