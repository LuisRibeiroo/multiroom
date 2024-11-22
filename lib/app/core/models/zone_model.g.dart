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
      volume: fields[3] as int,
      balance: fields[4] as int,
      equalizer: fields[5] as EqualizerModel,
      wrapperId: fields[7] == null ? '' : fields[7] as String,
      visible: fields[14] as bool,
      side: fields[6] as MonoSide,
      channel: fields[8] as ChannelModel,
      groupId: fields[9] == null ? '' : fields[9] as String,
      maxVolumeLeft: fields[10] == null ? 100 : fields[10] as int,
      maxVolumeRight: fields[11] == null ? 100 : fields[11] as int,
      deviceSerial: fields[12] == null ? '' : fields[12] as String,
      macAddress: fields[13] == null ? '' : fields[13] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ZoneModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.active)
      ..writeByte(3)
      ..write(obj.volume)
      ..writeByte(4)
      ..write(obj.balance)
      ..writeByte(5)
      ..write(obj.equalizer)
      ..writeByte(6)
      ..write(obj.side)
      ..writeByte(7)
      ..write(obj.wrapperId)
      ..writeByte(8)
      ..write(obj.channel)
      ..writeByte(9)
      ..write(obj.groupId)
      ..writeByte(10)
      ..write(obj.maxVolumeLeft)
      ..writeByte(11)
      ..write(obj.maxVolumeRight)
      ..writeByte(12)
      ..write(obj.deviceSerial)
      ..writeByte(13)
      ..write(obj.macAddress)
      ..writeByte(14)
      ..write(obj.visible);
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
