// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeviceTypeAdapter extends TypeAdapter<DeviceType> {
  @override
  final int typeId = 8;

  @override
  DeviceType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DeviceType.master;
      case 1:
        return DeviceType.slave;
      default:
        return DeviceType.master;
    }
  }

  @override
  void write(BinaryWriter writer, DeviceType obj) {
    switch (obj) {
      case DeviceType.master:
        writer.writeByte(0);
        break;
      case DeviceType.slave:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
