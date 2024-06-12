import 'package:equatable/equatable.dart';

import '../enums/device_type.dart';
import 'zone_model.dart';

class DeviceModel extends Equatable {
  const DeviceModel({
    required this.name,
    required this.ip,
    required this.zones,
    required this.version,
    required this.type,
  });

  factory DeviceModel.empty() {
    return const DeviceModel(
      name: "",
      ip: "",
      zones: [],
      version: "",
      type: DeviceType.master,
    );
  }

  factory DeviceModel.builder({
    required String name,
    required String ip,
  }) {
    return DeviceModel(
      name: name,
      zones: List.generate(
        8,
        (idx) => ZoneModel.builder(index: idx + 1, name: "Zona ${idx + 1}"),
      ),
      version: "1.0.0",
      type: DeviceType.master,
      ip: ip,
    );
  }

  final String name;
  final String ip;
  final List<ZoneModel> zones;
  final String version;
  final DeviceType type;

  bool get isEmpty => this == DeviceModel.empty();

  DeviceModel copyWith({
    String? name,
    String? ip,
    List<ZoneModel>? zones,
    String? version,
    DeviceType? type,
  }) {
    return DeviceModel(
      name: name ?? this.name,
      ip: ip ?? this.ip,
      zones: zones ?? this.zones,
      version: version ?? this.version,
      type: type ?? this.type,
    );
  }

  @override
  List<Object?> get props => [
        name,
        ip,
        zones,
        version,
        type,
      ];
}
