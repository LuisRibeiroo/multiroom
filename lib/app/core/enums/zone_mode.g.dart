// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zone_mode.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ZoneModeAdapter extends TypeAdapter<ZoneMode> {
  @override
  final int typeId = 10;

  @override
  ZoneMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ZoneMode.stereo;
      case 1:
        return ZoneMode.mono;
      default:
        return ZoneMode.stereo;
    }
  }

  @override
  void write(BinaryWriter writer, ZoneMode obj) {
    switch (obj) {
      case ZoneMode.stereo:
        writer.writeByte(0);
        break;
      case ZoneMode.mono:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ZoneModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
