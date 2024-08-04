import 'package:hive/hive.dart';

import '../enums/device_type.dart';
import 'zone_group_model.dart';
import 'zone_model.dart';
import 'zone_wrapper_model.dart';

part 'device_model.g.dart';

@HiveType(typeId: 1)
class DeviceModel extends HiveObject {
  DeviceModel({
    required this.serialNumber,
    required this.name,
    required this.ip,
    required this.zoneWrappers,
    required this.groups,
    required this.version,
    required this.type,
    this.active = true,
    required this.projectName,
    required this.projectId,
  });

  factory DeviceModel.empty() {
    return DeviceModel(
      serialNumber: "",
      name: "",
      ip: "",
      zoneWrappers: [],
      groups: [],
      version: "",
      type: DeviceType.master,
      projectName: "",
      projectId: "",
    );
  }

  factory DeviceModel.builder({
    required String projectName,
    required String projectId,
    required String serialNumber,
    required String name,
    required String ip,
    String? version,
    DeviceType? type,
  }) {
    return DeviceModel(
      projectId: projectId,
      projectName: projectName,
      serialNumber: serialNumber,
      name: name,
      zoneWrappers: List.generate(
        8,
        (idx) => ZoneWrapperModel.builder(index: idx + 1, name: "Zona ${idx + 1}"),
      ),
      groups: List.generate(
        3,
        (idx) => ZoneGroupModel.builder(index: idx + 1),
      ),
      version: version ?? "",
      type: type ?? DeviceType.master,
      ip: ip,
    );
  }

  factory DeviceModel.fromMap(Map<String, dynamic> map) {
    return DeviceModel(
      projectId: map['projectId'],
      projectName: map['projectName'],
      serialNumber: map['serialNumber'],
      name: map['name'],
      ip: map['ip'],
      zoneWrappers: List.from(map['zones']?.map((x) => ZoneWrapperModel.fromMap(x))),
      groups: List.from(map['groups']?.map((x) => ZoneGroupModel.fromMap(x))),
      version: map['version'],
      type: DeviceType.values[map['type']],
      active: map['active'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'projectName': projectName,
      'serialNumber': serialNumber,
      'name': name,
      'ip': ip,
      'zones': zoneWrappers.map((x) => x.toMap()).toList(),
      'groups': groups.map((x) => x.toMap()).toList(),
      'version': version,
      'type': type.index,
      'active': active,
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

  bool get isEmpty =>
      serialNumber == DeviceModel.empty().serialNumber &&
      name == DeviceModel.empty().name &&
      ip == DeviceModel.empty().ip;

  List<ZoneModel> get zones => zoneWrappers.fold(<ZoneModel>[], (pv, v) => pv..addAll(v.zones));

  bool get emptyGroups => groups.every((g) => g.hasZones == false);

  bool isZoneInGroup(ZoneModel zone) => groups.any((g) => g.zones.containsZone(zone)) || zone.isGroup;

  List<ZoneModel> get groupedZones {
    final temp = zones
        .where((zone) => groups.map((g) => g.zones.containsZone(zone)).every((v) => !v))
        .toList();

    for (final g in groups) {
      if (g.hasZones) {
        if (temp.where((z) => z.id == g.asZone.id).isEmpty) {
          temp.add(g.asZone);
        }
      }
    }

    return temp..sort((a, b) => a.id.compareTo(b.id));
  }

  DeviceModel copyWith({
    String? serialNumber,
    String? name,
    String? ip,
    List<ZoneWrapperModel>? zoneWrappers,
    List<ZoneGroupModel>? groups,
    String? version,
    DeviceType? type,
    bool? active,
    String? projectName,
    String? projectId,
  }) {
    return DeviceModel(
      serialNumber: serialNumber ?? this.serialNumber,
      name: name ?? this.name,
      ip: ip ?? this.ip,
      zoneWrappers: zoneWrappers ?? this.zoneWrappers,
      groups: groups ?? this.groups,
      version: version ?? this.version,
      type: type ?? this.type,
      active: active ?? this.active,
      projectName: projectName ?? this.projectName,
      projectId: projectId ?? this.projectId,
    );
  }

  @override
  String toString() {
    return 'DeviceModel(serialNumber: $serialNumber, name: $name, ip: $ip, projectId: $projectId, projectName: $projectName, zoneWrappers: $zoneWrappers, groups: $groups, version: $version, type: $type, projectId: $projectId, active: $active)';
  }
}
