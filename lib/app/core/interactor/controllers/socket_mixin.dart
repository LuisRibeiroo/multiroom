import 'dart:async';
import 'dart:io';

import '../../extensions/socket_extensions.dart';
import '../../extensions/stream_iterator_extensions.dart';
import '../../extensions/string_extensions.dart';

mixin SocketMixin {
  Socket? _socket;
  StreamIterator? _streamIterator;
  bool _lastCmdError = false;
  String? _ip;
  String? _lastIp;

  bool get socketInit => _socket != null;
  String get socketCurrentiP => _ip ?? "";

  Future<Socket> initSocket({required String ip}) async {
    _ip = ip;
    _lastIp = _ip;

    _socket = await Socket.connect(
      ip,
      4998,
      timeout: const Duration(seconds: 2),
    );

    _streamIterator = StreamIterator(_socket!);

    return _socket!;
  }

  Future<Socket> restartSocket({required String ip}) async {
    if (_socket != null) {
      _socket!
        ..close()
        ..destroy();
    }

    return initSocket(ip: ip);
  }

  Future<String> socketSender(String cmd, {bool longRet = false}) async {
    // Logger(
    //     printer: SimplePrinter(
    //   printTime: true,
    //   colors: false,
    // )).d("MOCK CMD --> [$cmd]");
    // return "mr_cmd=OK";

    if (_lastIp != _ip) {
      _lastCmdError = false;
    }

    if (_lastCmdError && _ip.isNotNullOrEmpty) {
      await restartSocket(ip: _ip!);
    }

    _lastIp = _ip;
    _lastCmdError = true;

    if (_socket == null || _streamIterator == null) {
      throw Exception("É necessário incializar o socket");
    }

    _socket!.writeLog(cmd);

    final data = await _streamIterator!.readSync(longResponse: longRet);

    _lastCmdError = false;

    return data;
  }

  void mixinDispose() {
    _socket
      ?..close()
      ..destroy();
    _streamIterator?.cancel();

    _socket = null;
    _streamIterator = null;
  }
}
