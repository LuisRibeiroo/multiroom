// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zone_wrapper_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ZoneWrapperModelAdapter extends TypeAdapter<ZoneWrapperModel> {
  @override
  final int typeId = 7;

  @override
  ZoneWrapperModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ZoneWrapperModel(
      id: fields[0] as String,
      mode: fields[1] as ZoneMode,
      stereoZone: fields[2] as ZoneModel,
      monoZones: fields[3] as MonoZones,
    );
  }

  @override
  void write(BinaryWriter writer, ZoneWrapperModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.mode)
      ..writeByte(2)
      ..write(obj.stereoZone)
      ..writeByte(3)
      ..write(obj.monoZones);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ZoneWrapperModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
