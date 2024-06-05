import 'package:equatable/equatable.dart';

import '../../../../core/enums/device_type.dart';
import '../../../../core/models/input_model.dart';
import '../../../../core/models/net_address_model.dart';
import '../../../../core/models/zone_model.dart';

class DeviceModel extends Equatable {
  const DeviceModel({
    required this.name,
    required this.netAddress,
    required this.inputs,
    required this.zones,
    required this.version,
    required this.type,
  });

  factory DeviceModel.empty() {
    return DeviceModel(
      name: '',
      netAddress: NetAddressModel.empty(),
      inputs: const [],
      zones: const [],
      version: '',
      type: DeviceType.master,
    );
  }

  factory DeviceModel.builder({
    required String name,
    required String ip,
    required int port,
  }) {
    final separatedIp = ip.split(".");

    return DeviceModel(
      name: name,
      inputs: List.generate(
        8,
        (idx) => InputModel.builder(name: "Input ${idx + 1}"),
      ),
      zones: List.generate(
        8,
        (idx) => ZoneModel.builder(index: idx + 1, name: "Zona ${idx + 1}"),
      ),
      version: "1.0.0",
      type: DeviceType.master,
      netAddress: NetAddressModel(
        ip: ip,
        port: port,
        mask: "255.255.255.0",
        gateway: separatedIp.sublist(0, 3).join(".1"),
      ),
    );
  }

  final String name;
  final NetAddressModel netAddress;
  final List<InputModel> inputs;
  final List<ZoneModel> zones;
  final String version;
  final DeviceType type;

  bool get isEmpty => this == DeviceModel.empty();

  DeviceModel copyWith({
    String? name,
    NetAddressModel? netAddress,
    List<InputModel>? inputs,
    List<ZoneModel>? zones,
    String? version,
    DeviceType? type,
  }) {
    return DeviceModel(
      name: name ?? this.name,
      netAddress: netAddress ?? this.netAddress,
      inputs: inputs ?? this.inputs,
      zones: zones ?? this.zones,
      version: version ?? this.version,
      type: type ?? this.type,
    );
  }

  @override
  List<Object?> get props => [
        name,
        netAddress,
        inputs,
        zones,
        version,
        type,
      ];
}
