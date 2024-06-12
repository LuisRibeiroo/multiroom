import 'package:equatable/equatable.dart';
import 'package:multiroom/app/core/enums/device_type.dart';

class TechnicianDeviceModel extends Equatable {
  const TechnicianDeviceModel({
    required this.ip,
    required this.version,
    required this.type,
    this.active = true,
    this.masterName = "",
  });

  factory TechnicianDeviceModel.empty() => const TechnicianDeviceModel(
        ip: "",
        version: "",
        type: DeviceType.master,
        masterName: "",
        active: true,
      );

  factory TechnicianDeviceModel.builder({
    required String ip,
  }) =>
      TechnicianDeviceModel(
        ip: ip,
        version: "",
        type: DeviceType.master,
        masterName: "",
        active: true,
      );

  final String ip;
  final String version;
  final DeviceType type;
  final String masterName;
  final bool active;

  bool get isEmpty => this == TechnicianDeviceModel.empty();

  TechnicianDeviceModel copyWith({
    String? ip,
    String? version,
    DeviceType? type,
    String? masterName,
    bool? active,
  }) {
    return TechnicianDeviceModel(
      ip: ip ?? this.ip,
      version: version ?? this.version,
      type: type ?? this.type,
      masterName: masterName ?? this.masterName,
      active: active ?? this.active,
    );
  }

  @override
  List<Object?> get props => [
        ip,
        version,
        type,
        masterName,
        active,
      ];
}
