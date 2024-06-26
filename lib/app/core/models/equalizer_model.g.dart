// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equalizer_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EqualizerModelAdapter extends TypeAdapter<EqualizerModel> {
  @override
  final int typeId = 2;

  @override
  EqualizerModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EqualizerModel(
      name: fields[0] as String,
      frequencies: (fields[1] as List).cast<Frequency>(),
    );
  }

  @override
  void write(BinaryWriter writer, EqualizerModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.frequencies);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EqualizerModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
