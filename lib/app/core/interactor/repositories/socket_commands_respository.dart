import 'dart:async';

import 'package:signals/signals_flutter.dart';

import '../../enums/multiroom_commands.dart';
import '../../utils/constants.dart';

final class _CommandTimerCallback {
  _CommandTimerCallback({
    required this.macAddress,
    required this.cmd,
    required this.timer,
  });

  final String macAddress;
  final MultiroomCommands cmd;
  late final Timer timer;
}

final class SocketCommandsRespository {
  final errorSignal = ''.asSignal();
  final Map<String, _CommandTimerCallback> _timers = {};
  final List<String> _receivedCommands = [];

  void addCommand(String macAddress, MultiroomCommands cmd) {
    final key = _toKey(macAddress, cmd);

    _timers.build(
      _CommandTimerCallback(
        macAddress: macAddress,
        cmd: cmd,
        timer: Timer(
          const Duration(seconds: readTimeout),
          () {
            if (_receivedCommands.contains(key)) {
              _receivedCommands.remove(key);
            } else {
              errorSignal.value = "Cmd Timeout [$macAddress][${cmd.value}]";
            }

            _timers.delete(key);
          },
        ),
      ),
    );
  }

  void addResponse(String macAddress, MultiroomCommands cmd) {
    _receivedCommands.add(_toKey(macAddress, cmd));
  }

  String _toKey(String macAddress, MultiroomCommands cmd) => "${macAddress}_${cmd.asSet()}";
}

extension _TimerExtension on Map<String, _CommandTimerCallback> {
  String build(_CommandTimerCallback callback) {
    final key = "${callback.macAddress}_${callback.cmd}_${callback.hashCode}";

    if (containsKey(key)) {
      this[key]!.timer.cancel();
    }

    this[key] = callback;

    return key;
  }

  void delete(String key) {
    if (containsKey(key)) {
      this[key]!.timer.cancel();
      remove(key);
    }
  }
}
