// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mono_side.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MonoSideAdapter extends TypeAdapter<MonoSide> {
  @override
  final int typeId = 9;

  @override
  MonoSide read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MonoSide.undefined;
      case 1:
        return MonoSide.left;
      case 2:
        return MonoSide.right;
      default:
        return MonoSide.undefined;
    }
  }

  @override
  void write(BinaryWriter writer, MonoSide obj) {
    switch (obj) {
      case MonoSide.undefined:
        writer.writeByte(0);
        break;
      case MonoSide.left:
        writer.writeByte(1);
        break;
      case MonoSide.right:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonoSideAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
