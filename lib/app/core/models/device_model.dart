import 'package:equatable/equatable.dart';

import '../enums/device_type.dart';
import 'selectable_model.dart';
import 'zone_wrapper_model.dart';

class DeviceModel extends Equatable implements SelectableModel {
  const DeviceModel({
    required this.serialNumber,
    required this.name,
    required this.ip,
    required this.zoneWrappers,
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
  final String version;
  final DeviceType type;
  final String masterName;
  final bool active;

  bool get isEmpty => this == DeviceModel.empty();

  @override
  String get label => name;

  DeviceModel copyWith({
    String? serialNumber,
    String? name,
    String? ip,
    List<ZoneWrapperModel>? zones,
    String? version,
    DeviceType? type,
    String? masterName,
    bool? active,
  }) {
    return DeviceModel(
      serialNumber: serialNumber ?? this.serialNumber,
      name: name ?? this.name,
      ip: ip ?? this.ip,
      zoneWrappers: zones ?? zoneWrappers,
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
        version,
        type,
        masterName,
        active,
      ];
}
