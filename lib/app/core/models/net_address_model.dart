import 'package:equatable/equatable.dart';

class NetAddressModel extends Equatable {
  const NetAddressModel({
    required this.ip,
    required this.port,
    required this.mask,
    required this.gateway,
  });

  final String ip;
  final int port;
  final String mask;
  final String gateway;

  @override
  List<Object?> get props => [
        ip,
        port,
        gateway,
        mask,
      ];
}
