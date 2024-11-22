import 'package:hive/hive.dart';

import '../enums/device_type.dart';
import 'channel_model.dart';
import 'zone_group_model.dart';
import 'zone_model.dart';
import 'zone_wrapper_model.dart';

part 'device_model.g.dart';

@HiveType(typeId: 1)
class DeviceModel extends HiveObject {
  DeviceModel({
    required this.serialNumber,
    required this.macAddress,
    required this.name,
    required this.ip,
    required this.zoneWrappers,
    required this.groups,
    required this.version,
    required this.type,
    this.active = true,
    required this.projectName,
    required this.projectId,
    required this.channels,
  });

  factory DeviceModel.empty() {
    return DeviceModel(
      serialNumber: "",
      macAddress: "",
      name: "",
      ip: "",
      zoneWrappers: [],
      groups: [],
      version: "",
      type: DeviceType.master,
      projectName: "",
      projectId: "",
      channels: const [],
    );
  }

  factory DeviceModel.builder({
    required String projectName,
    required String projectId,
    required String serialNumber,
    required String macAddress,
    required String name,
    required String ip,
    String? version,
    DeviceType? type,
  }) {
    return DeviceModel(
      projectId: projectId,
      projectName: projectName,
      serialNumber: serialNumber,
      macAddress: macAddress,
      name: name,
      zoneWrappers: List.generate(
        8,
        (idx) => ZoneWrapperModel.builder(
          index: idx + 1,
          name: "Zona ${idx + 1}",
          deviceSerial: serialNumber,
          macAddress: macAddress,
        ),
      ),
      groups: List.generate(
        8,
        (idx) => ZoneGroupModel.builder(index: idx + 1),
      ),
      version: version ?? "",
      type: type ?? DeviceType.master,
      ip: ip,
      channels: List.generate(
        8,
        (idx) => ChannelModel.builder(index: idx + 1, name: "Input ${idx + 1}"),
      ),
    );
  }

  factory DeviceModel.fromMap(Map<String, dynamic> map) {
    return DeviceModel(
      projectId: map['projectId'],
      projectName: map['projectName'],
      serialNumber: map['serialNumber'],
      macAddress: map['macAddress'],
      name: map['name'],
      ip: map['ip'],
      zoneWrappers: List.from(map['zones']?.map((x) => ZoneWrapperModel.fromMap(x))),
      groups: List.from(map['groups']?.map((x) => ZoneGroupModel.fromMap(x))),
      version: map['version'],
      type: DeviceType.values[map['type']],
      active: map['active'],
      channels: List<ChannelModel>.from(map['channels']?.map((x) => ChannelModel.fromMap(x))),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'projectName': projectName,
      'serialNumber': serialNumber,
      'macAddress': macAddress,
      'name': name,
      'ip': ip,
      'zones': zoneWrappers.map((x) => x.toMap()).toList(),
      'groups': groups.map((x) => x.toMap()).toList(),
      'version': version,
      'type': type.index,
      'active': active,
      'channels': channels.map((x) => x.toMap()).toList(),
    };
  }

  @HiveField(0)
  final String serialNumber;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String ip;
  @HiveField(3)
  final List<ZoneWrapperModel> zoneWrappers;
  @HiveField(4)
  final List<ZoneGroupModel> groups;
  @HiveField(5)
  final String version;
  @HiveField(6)
  final DeviceType type;
  @HiveField(7)
  final String projectName;
  @HiveField(8)
  final bool active;
  @HiveField(9)
  final String projectId;
  @HiveField(10)
  final String macAddress;
  @HiveField(11)
  final List<ChannelModel> channels;

  bool get isEmpty =>
      serialNumber == DeviceModel.empty().serialNumber &&
      name == DeviceModel.empty().name &&
      ip == DeviceModel.empty().ip;

  List<ZoneModel> get zones => zoneWrappers.fold(<ZoneModel>[], (pv, v) => pv..addAll(v.zones));

  bool get emptyGroups => groups.every((g) => g.hasZones == false);

  bool isZoneInGroup(ZoneModel zone) => groups.any((g) => g.zones.containsZone(zone));

  List<ZoneModel> get groupedZones => zones.grouped(groups);

  DeviceModel copyWith({
    String? serialNumber,
    String? macAddress,
    String? name,
    String? ip,
    List<ZoneWrapperModel>? zoneWrappers,
    List<ZoneGroupModel>? groups,
    String? version,
    DeviceType? type,
    bool? active,
    String? projectName,
    String? projectId,
    List<ChannelModel>? channels,
  }) {
    return DeviceModel(
      serialNumber: serialNumber ?? this.serialNumber,
      macAddress: macAddress ?? this.macAddress,
      name: name ?? this.name,
      ip: ip ?? this.ip,
      zoneWrappers: zoneWrappers ?? this.zoneWrappers,
      groups: groups ?? this.groups,
      version: version ?? this.version,
      type: type ?? this.type,
      active: active ?? this.active,
      projectName: projectName ?? this.projectName,
      projectId: projectId ?? this.projectId,
      channels: channels ?? this.channels,
    );
  }

  @override
  String toString() {
    return 'DeviceModel(serialNumber: $serialNumber, name: $name, ip: $ip, macAddress: $macAddress, projectId: $projectId, projectName: $projectName, zoneWrappers: $zoneWrappers, groups: $groups, version: $version, type: $type, projectId: $projectId, active: $active, channels: $channels)';
  }
}
