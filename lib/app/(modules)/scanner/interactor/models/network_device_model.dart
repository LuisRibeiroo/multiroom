import 'package:equatable/equatable.dart';

class NetworkDeviceModel extends Equatable {
  const NetworkDeviceModel({
    required this.ip,
    required this.firmware,
    required this.serialNumber,
  });

  factory NetworkDeviceModel.empty() => const NetworkDeviceModel(
        ip: "",
        firmware: "",
        serialNumber: "",
      );

  NetworkDeviceModel copyWith({
    String? ip,
    String? firmware,
    String? serialNumber,
  }) {
    return NetworkDeviceModel(
      ip: ip ?? this.ip,
      firmware: firmware ?? this.firmware,
      serialNumber: serialNumber ?? this.serialNumber,
    );
  }

  final String ip;
  final String firmware;
  final String serialNumber;

  @override
  List<Object?> get props => [
        ip,
        firmware,
        serialNumber,
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
