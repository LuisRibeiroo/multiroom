import 'dart:async';
import 'dart:io';

import '../../extensions/socket_extensions.dart';
import '../../extensions/stream_iterator_extensions.dart';

mixin SocketMixin {
  Socket? _socket;
  StreamIterator? _streamIterator;

  Future<void> initSocket({required String ip}) async {
    _socket = await Socket.connect(
      ip,
      4998,
      timeout: const Duration(seconds: 2),
    );

    _streamIterator = StreamIterator(_socket!);
  }

  Future<String> socketSender(String cmd, {bool longRet = false}) async {
    if (_socket == null || _streamIterator == null) {
      throw StateError("É necessário incializar o socket");
    }

    _socket!.writeLog(cmd);
    return await _streamIterator!.readSync(longResponse: longRet);
  }

  void mixinDispose() {
    _socket?.close();
    _streamIterator?.cancel();

    _socket = null;
    _streamIterator = null;
  }
}
