import 'dart:io';

import 'package:collection/collection.dart';

import '../extensions/socket_extensions.dart';
import '../extensions/string_extensions.dart';

final class SocketConnection {
  const SocketConnection({
    required this.ip,
    required this.macAddress,
    required this.socket,
  });

  final String ip;
  final String macAddress;
  final Socket socket;
}

extension SocketConnectionExt on Map<String, SocketConnection> {
  String _getIp(String macAddress) {
    final connection = values.firstWhereOrNull(
      (element) => element.macAddress == macAddress,
    );

    if (connection == null) {
      throw Exception("MacAddress não encontrado");
    }

    return connection.ip;
  }

  Future<void> listenTo({
    required String ip,
    required void Function(String) onData,
    void Function(String)? onError,
  }) async {
    final connection = this[ip];

    if (connection == null) {
      throw Exception("Conexão não encontrada");
    }

    connection.socket.listenString(onData: onData, onError: onError);
  }

  Future<void> listenAll({
    required void Function(String) onData,
    void Function(String)? onError,
  }) async {
    for (final connection in values) {
      listenTo(
        ip: connection.ip,
        onData: onData,
        onError: onError,
      );
    }
  }

  void updateSocket({required String ip, required Socket socket}) {
    if (this[ip] == null) {
      throw Exception("Conexão não encontrada");
    }

    this[ip] = SocketConnection(
      ip: ip,
      macAddress: this[ip]!.macAddress,
      socket: socket,
    );
  }

  void send({
    required String cmd,
    String? ip,
    String? macAddress,
  }) {
    if (ip.isNullOrEmpty && macAddress.isNullOrEmpty) {
      throw Exception("É necessário informar o IP ou o MAC Address");
    }

    if (ip.isNullOrEmpty) {
      ip = _getIp(macAddress!);
    }

    final connection = this[ip];

    try {
      if (connection == null) {
        throw Exception("Conexão não encontrada");
      }

      connection.socket.writeLog(cmd);
    } catch (exception) {
      connection?.socket.close();
      throw Exception("Enviar comando [$ip][$cmd] -> $exception");
    }
  }
}
