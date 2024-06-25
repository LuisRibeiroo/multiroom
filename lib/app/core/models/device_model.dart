import 'package:equatable/equatable.dart';

import '../enums/device_type.dart';
import 'zone_group_model.dart';
import 'zone_model.dart';
import 'zone_wrapper_model.dart';

class DeviceModel extends Equatable {
  const DeviceModel({
    required this.serialNumber,
    required this.name,
    required this.ip,
    required this.zoneWrappers,
    required this.groups,
    required this.version,
    required this.type,
    this.active = true,
    this.masterName = "",
  });

  factory DeviceModel.empty() {
    return const DeviceModel(
      serialNumber: "",
      name: "",
      ip: "",
      zoneWrappers: [],
      groups: [],
      version: "",
      type: DeviceType.master,
    );
  }

  factory DeviceModel.builder({
    required String serialNumber,
    required String name,
    required String ip,
    String? version,
    DeviceType? type,
  }) {
    return DeviceModel(
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
      serialNumber: map['serialNumber'],
      name: map['name'],
      ip: map['ip'],
      zoneWrappers: List.from(map['zones']?.map((x) => ZoneWrapperModel.fromMap(x))),
      groups: List.from(map['groups']?.map((x) => ZoneGroupModel.fromMap(x))),
      version: map['version'],
      type: DeviceType.values[map['type']],
      masterName: map['masterName'],
      active: map['active'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'serialNumber': serialNumber,
      'name': name,
      'ip': ip,
      'zones': zoneWrappers.map((x) => x.toMap()).toList(),
      'groups': groups.map((x) => x.toMap()).toList(),
      'version': version,
      'type': type.index,
      'masterName': masterName,
      'active': active,
    };
  }

  final String serialNumber;
  final String name;
  final String ip;
  final List<ZoneWrapperModel> zoneWrappers;
  final List<ZoneGroupModel> groups;
  final String version;
  final DeviceType type;
  final String masterName;
  final bool active;

  bool get isEmpty => this == DeviceModel.empty();

  List<ZoneModel> get zones => zoneWrappers.fold(<ZoneModel>[], (pv, v) => pv..addAll(v.zones));

  bool get emptyGroups => groups.every((g) => g.hasZones == false);

  bool isZoneInGroup(ZoneModel zone) => groups.any((g) => g.zones.contains(zone));

  List<ZoneModel> get groupedZones {
    final temp = zones.where((zone) => groups.map((g) => g.zones.contains(zone)).every((v) => !v)).toList();

    for (final g in groups) {
      if (g.hasZones) {
        if (temp.where((z) => z.name == g.asZone.name).isEmpty) {
          temp.add(g.asZone);
        }
      }
    }

    return temp..sort((a, b) => a.name.compareTo(b.name));
  }

  DeviceModel copyWith({
    String? serialNumber,
    String? name,
    String? ip,
    List<ZoneWrapperModel>? zoneWrappers,
    List<ZoneGroupModel>? groups,
    String? version,
    DeviceType? type,
    String? masterName,
    bool? active,
  }) {
    return DeviceModel(
      serialNumber: serialNumber ?? this.serialNumber,
      name: name ?? this.name,
      ip: ip ?? this.ip,
      zoneWrappers: zoneWrappers ?? this.zoneWrappers,
      groups: groups ?? this.groups,
      version: version ?? this.version,
      type: type ?? this.type,
      masterName: masterName ?? this.masterName,
      active: active ?? this.active,
    );
  }

  @override
  List<Object?> get props => [
        serialNumber,
        name,
        ip,
        zoneWrappers,
        groups,
        version,
        type,
        masterName,
        active,
      ];
}
