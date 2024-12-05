import 'dart:io';

import '../extensions/socket_extensions.dart';

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
  Future<void> listenTo({
    required String ip,
    required void Function(String) onData,
  }) async {
    final connection = this[ip];

    if (connection == null) {
      throw Exception("Conexão não encontrada");
    }

    connection.socket.listenString(onData);
  }

  Future<void> listenAll({
    required void Function(String) onData,
  }) async {
    for (final connection in values) {
      listenTo(
        ip: connection.ip,
        onData: onData,
      );
    }
  }

  void send({required String ip, required String cmd}) {
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
