// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mono_zones.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MonoZonesAdapter extends TypeAdapter<MonoZones> {
  @override
  final int typeId = 11;

  @override
  MonoZones read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MonoZones(
      left: fields[0] as ZoneModel,
      right: fields[1] as ZoneModel,
    );
  }

  @override
  void write(BinaryWriter writer, MonoZones obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.left)
      ..writeByte(1)
      ..write(obj.right);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonoZonesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
