import 'package:equatable/equatable.dart';
import 'package:multiroom/app/core/enums/device_type.dart';

class TechnicianDeviceModel extends Equatable {
  const TechnicianDeviceModel({
    required this.serialNumber,
    required this.ip,
    required this.version,
    required this.type,
    this.active = true,
    this.masterName = "",
  });

  factory TechnicianDeviceModel.empty() => const TechnicianDeviceModel(
        serialNumber: "",
        ip: "",
        version: "",
        type: DeviceType.master,
        masterName: "",
        active: true,
      );

  factory TechnicianDeviceModel.builder({
    required String serialNumber,
    required String ip,
  }) =>
      TechnicianDeviceModel(
        serialNumber: serialNumber,
        ip: ip,
        version: "",
        type: DeviceType.master,
        masterName: "",
        active: true,
      );

  final String serialNumber;
  final String ip;
  final String version;
  final DeviceType type;
  final String masterName;
  final bool active;

  bool get isEmpty => this == TechnicianDeviceModel.empty();

  TechnicianDeviceModel copyWith({
    String? serialNumber,
    String? ip,
    String? version,
    DeviceType? type,
    String? masterName,
    bool? active,
  }) {
    return TechnicianDeviceModel(
      serialNumber: serialNumber ?? this.serialNumber,
      ip: ip ?? this.ip,
      version: version ?? this.version,
      type: type ?? this.type,
      masterName: masterName ?? this.masterName,
      active: active ?? this.active,
    );
  }

  @override
  List<Object?> get props => [
        serialNumber,
        ip,
        version,
        type,
        masterName,
        active,
      ];
}
