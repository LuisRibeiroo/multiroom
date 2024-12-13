import 'dart:io';

import 'package:collection/collection.dart';
import 'package:logger/logger.dart';

import '../enums/multiroom_commands.dart';
import '../extensions/socket_extensions.dart';
import '../extensions/string_extensions.dart';
import '../interactor/repositories/socket_commands_respository.dart';
import '../utils/mr_cmd_builder.dart';

final class SocketConnection {
  SocketConnection({
    required this.ip,
    required this.macAddress,
    required this.socket,
  });

  final String ip;
  final String macAddress;
  final Socket socket;
  final SocketCommandsRespository _commandsRespository = SocketCommandsRespository();
  late final errorSignal = _commandsRespository.errorSignal;

  void addCommand(MultiroomCommands cmd) {
    _commandsRespository.addCommand(macAddress, cmd);
  }

  void addResponse(MultiroomCommands cmd) {
    _commandsRespository.addResponse(macAddress, cmd);
  }
}

extension SocketConnectionExt on Map<String, SocketConnection> {
  String _getIp(String macAddress) {
    final connection = values.firstWhereOrNull(
      (element) => element.macAddress.toUpperCase() == macAddress.toUpperCase(),
    );

    if (connection == null) {
      throw Exception("MacAddress não encontrado");
    }

    return connection.ip;
  }

  Future<void> listenTo({
    required String ip,
    required void Function(String) onData,
    void Function(String, String)? onError,
  }) async {
    final connection = this[ip];

    if (connection == null) {
      throw Exception("Conexão não encontrada");
    }

    connection.socket.listenString(
      onData: (data) {
        try {
          for (final cmd in MrCmdBuilder.parseResponse(data).groupedByCmd()) {
            connection.addResponse(cmd);
          }
          onData(data);
        } catch (exception) {
          onError?.call(exception.toString(), ip);
        }
      },
      onError: (msg) => onError?.call(msg, ip),
    );

    connection.errorSignal.subscribe((error) {
      if (error.isNotNullOrEmpty) {
        onError?.call(error, ip);
      }
    });

    Logger(
        printer: SimplePrinter(
      printTime: true,
      colors: false,
    )).d("[SOCKET] listening on IP [$ip]");
  }

  Future<void> listenAll({
    required void Function(String) onData,
    void Function(String, String)? onError,
  }) async {
    for (final connection in values) {
      listenTo(
        ip: connection.ip,
        onData: onData,
        onError: onError,
      );
    }
  }

  Future<void> cancelAll() async {
    for (final connection in values) {
      connection.socket.close();
      connection.socket.destroy();
    }

    clear();
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
      connection.addCommand(MultiroomCommands.fromString(cmd)!);
    } catch (exception) {
      connection?.socket
        ?..close()
        ..destroy();
      throw Exception("Enviar comando [$ip][$cmd] -> $exception");
    }
  }
}
