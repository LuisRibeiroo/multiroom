import 'string_extensions.dart';

extension MapExt<T, E> on Map<T, E>? {
  void removeNulls() {
    if (this == null) {
      return;
    }
    final keysToRemove = [];

    for (final entry in this!.entries) {
      if (entry.key.toString().isNullOrEmpty || entry.value == null) {
        keysToRemove.add(entry.key);
      }
    }

    for (final element in keysToRemove) {
      this!.remove(element);
    }
  }

  void addAllAbsent(Map<T, E> map) {
    if (this == null) {
      return;
    }

    for (final entry in map.entries) {
      if (this!.keys.contains(entry.key) == false) {
        this![entry.key] = entry.value;
      }
    }
  }
}
