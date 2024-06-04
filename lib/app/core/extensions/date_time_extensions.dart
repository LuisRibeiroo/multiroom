import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateTimeExt on DateTime {
  String get dateString => DateFormat.yMMMd().format(this);

  DateTime get toDate => DateTime(year, month, day);
  TimeOfDay get toTime => TimeOfDay.fromDateTime(this);
}
