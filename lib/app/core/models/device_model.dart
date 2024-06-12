import 'package:equatable/equatable.dart';

import '../enums/device_type.dart';
import 'zone_wrapper_model.dart';

class DeviceModel extends Equatable {
  const DeviceModel({
    required this.serialNumber,
    required this.name,
    required this.ip,
    required this.zones,
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
      zones: [],
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
      zones: List.generate(
        8,
        (idx) => ZoneWrapperModel.builder(index: idx + 1, name: "Zona ${idx + 1}"),
      ),
      version: version ?? "",
      type: type ?? DeviceType.master,
      ip: ip,
    );
  }

  final String serialNumber;
  final String name;
  final String ip;
  final List<ZoneWrapperModel> zones;
  final String version;
  final DeviceType type;
  final String masterName;
  final bool active;

  bool get isEmpty => this == DeviceModel.empty();

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
      zones: zones ?? this.zones,
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
        zones,
        version,
        type,
        masterName,
        active,
      ];
}
