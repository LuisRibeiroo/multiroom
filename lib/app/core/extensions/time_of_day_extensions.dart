import 'package:flutter/material.dart';

extension TimeOfDayExt on TimeOfDay {
  Duration get duration => Duration(hours: hour, minutes: minute);
  DateTime get toDateTime => DateTime(0, 0, 0, hour, minute);

  String get toTimestamp => "$hour:$minute";

  static TimeOfDay fromTimestamp(String timestamp) {
    final time = timestamp.split(":");
    return TimeOfDay(hour: int.parse(time[0]), minute: int.parse(time[1]));
  }

  bool isBetween(TimeOfDay start, TimeOfDay end) {
    final slotTIme = toDateTime;
    final startTime = start.toDateTime;
    final endTime = end.toDateTime;

    final isAfterStart =
        slotTIme.isAfter(startTime) || slotTIme.isAtSameMomentAs(startTime);
    final isBeforeEnd = slotTIme.isBefore(endTime);

    // debugPrint("Vezes comparadas");
    return isAfterStart && isBeforeEnd;
  }
}
