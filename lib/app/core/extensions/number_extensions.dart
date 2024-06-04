import 'package:flutter/material.dart';

extension NumExt on num {
  Widget get asSpace => SizedBox(width: toDouble(), height: toDouble());
}
