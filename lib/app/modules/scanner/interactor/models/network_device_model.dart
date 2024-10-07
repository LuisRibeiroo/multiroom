import 'package:equatable/equatable.dart';

class NetworkDeviceModel extends Equatable {
  const NetworkDeviceModel({
    required this.ip,
    required this.firmware,
    required this.serialNumber,
    required this.macAddress
  });

  factory NetworkDeviceModel.empty() => const NetworkDeviceModel(
        ip: "",
        firmware: "",
        serialNumber: "",
        macAddress: ""
      );

  NetworkDeviceModel copyWith({
    String? ip,
    String? firmware,
    String? serialNumber,
    String? macAddress
  }) {
    return NetworkDeviceModel(
      ip: ip ?? this.ip,
      firmware: firmware ?? this.firmware,
      serialNumber: serialNumber ?? this.serialNumber,
      macAddress: macAddress ?? this.macAddress
    );
  }

  final String ip;
  final String firmware;
  final String serialNumber;
  final String macAddress;

  @override
  List<Object?> get props => [
        ip,
        firmware,
        serialNumber,
        macAddress,
      ];
}

enum NetworkDeviceType {
  undefined,
  master,
  slave1,
  slave2;

  String get readable => switch (this) {
        undefined => "Não definido",
        master => "Master 1",
        slave1 => "Slave 1",
        slave2 => "Slave 2",
      };
}
