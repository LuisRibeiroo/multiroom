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
      volume: fields[5] as int,
      balance: fields[6] as int,
      equalizer: fields[7] as EqualizerModel,
      wrapperId: fields[9] == null ? '' : fields[9] as String,
      visible: fields[17] as bool,
      side: fields[8] as MonoSide,
      channel: fields[11] == null
          ? const ChannelModel.empty()
          : fields[11] as ChannelModel,
      groupId: fields[12] == null ? '' : fields[12] as String,
      maxVolumeLeft: fields[13] == null ? 100 : fields[13] as int,
      maxVolumeRight: fields[14] == null ? 100 : fields[14] as int,
      deviceSerial: fields[15] == null ? '' : fields[15] as String,
      macAddress: fields[16] == null ? '' : fields[16] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ZoneModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.active)
      ..writeByte(3)
      ..write(obj.channels)
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
      ..writeByte(11)
      ..write(obj.channel)
      ..writeByte(12)
      ..write(obj.groupId)
      ..writeByte(13)
      ..write(obj.maxVolumeLeft)
      ..writeByte(14)
      ..write(obj.maxVolumeRight)
      ..writeByte(15)
      ..write(obj.deviceSerial)
      ..writeByte(16)
      ..write(obj.macAddress)
      ..writeByte(17)
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
