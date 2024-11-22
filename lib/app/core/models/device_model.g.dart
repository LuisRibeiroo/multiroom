// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeviceModelAdapter extends TypeAdapter<DeviceModel> {
  @override
  final int typeId = 1;

  @override
  DeviceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeviceModel(
      serialNumber: fields[0] as String,
      macAddress: fields[10] as String,
      name: fields[1] as String,
      ip: fields[2] as String,
      zoneWrappers: (fields[3] as List).cast<ZoneWrapperModel>(),
      groups: (fields[4] as List).cast<ZoneGroupModel>(),
      version: fields[5] as String,
      type: fields[6] as DeviceType,
      active: fields[8] as bool,
      projectName: fields[7] as String,
      projectId: fields[9] as String,
      channels: (fields[11] as List).cast<ChannelModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, DeviceModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.serialNumber)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.ip)
      ..writeByte(3)
      ..write(obj.zoneWrappers)
      ..writeByte(4)
      ..write(obj.groups)
      ..writeByte(5)
      ..write(obj.version)
      ..writeByte(6)
      ..write(obj.type)
      ..writeByte(7)
      ..write(obj.projectName)
      ..writeByte(8)
      ..write(obj.active)
      ..writeByte(9)
      ..write(obj.projectId)
      ..writeByte(10)
      ..write(obj.macAddress)
      ..writeByte(11)
      ..write(obj.channels);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
