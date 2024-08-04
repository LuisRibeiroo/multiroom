// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zone_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ZoneModelAdapter extends TypeAdapter<ZoneModel> {
  @override
  final int typeId = 6;

  @override
  ZoneModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ZoneModel(
      id: fields[0] as String,
      name: fields[1] as String,
      active: fields[2] as bool,
      channels: (fields[3] as List).cast<ChannelModel>(),
      maxVolume: fields[4] as int,
      volume: fields[5] as int,
      balance: fields[6] as int,
      equalizer: fields[7] as EqualizerModel,
      wrapperId: fields[9] == null ? '' : fields[9] as String,
      side: fields[8] as MonoSide,
      isGroup: fields[10] == null ? false : fields[10] as bool,
      channel: fields[11] == null
          ? const ChannelModel.empty()
          : fields[11] as ChannelModel,
      groupId: fields[12] == null ? '' : fields[12] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ZoneModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.active)
      ..writeByte(3)
      ..write(obj.channels)
      ..writeByte(4)
      ..write(obj.maxVolume)
      ..writeByte(5)
      ..write(obj.volume)
      ..writeByte(6)
      ..write(obj.balance)
      ..writeByte(7)
      ..write(obj.equalizer)
      ..writeByte(8)
      ..write(obj.side)
      ..writeByte(9)
      ..write(obj.wrapperId)
      ..writeByte(10)
      ..write(obj.isGroup)
      ..writeByte(11)
      ..write(obj.channel)
      ..writeByte(12)
      ..write(obj.groupId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ZoneModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
