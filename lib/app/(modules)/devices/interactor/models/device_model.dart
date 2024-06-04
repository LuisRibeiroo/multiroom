import 'package:equatable/equatable.dart';

import '../../../../core/enums/device_type.dart';
import '../../../../core/models/equalizer.dart';
import '../../../../core/models/input_model.dart';
import '../../../../core/models/net_address_model.dart';
import '../../../../core/models/zone_model.dart';

class DeviceModel extends Equatable {
  const DeviceModel({
    required this.name,
    required this.netAddress,
    required this.inputs,
    required this.zones,
    required this.equalizers,
    required this.version,
    required this.type,
  });

  final String name;
  final NetAddressModel netAddress;
  final List<InputModel> inputs;
  final List<ZoneModel> zones;
  final List<Equalizer> equalizers;
  final String version;
  final DeviceType type;

  DeviceModel copyWith({
    String? name,
    NetAddressModel? netAddress,
    List<InputModel>? inputs,
    List<ZoneModel>? zones,
    List<Equalizer>? equalizers,
    String? version,
    DeviceType? type,
  }) {
    return DeviceModel(
      name: name ?? this.name,
      netAddress: netAddress ?? this.netAddress,
      inputs: inputs ?? this.inputs,
      zones: zones ?? this.zones,
      equalizers: equalizers ?? this.equalizers,
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
        equalizers,
        version,
        type,
      ];
}
