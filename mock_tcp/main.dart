import 'dart:io';
import 'dart:math';

import 'package:logger/logger.dart';

import 'multiroom_commands.dart';

final logger = Logger(
    printer: SimplePrinter(
  printTime: true,
));

final port = 4998;

Future<void> runServer(ServerSocket server) async {
  try {
    server.listen(
      (socket) {
        logger.d("*** New Connection ***");

        socket.listen(
          (data) async {
            if (data.singleOrNull != null) return;

            try {
              final strData =
                  new String.fromCharCodes(data).replaceAll("\n", "");
              logger.d("<<< ${strData}");

              final cmd =
                  MultiroomCommands.fromString(strData.split(",").first);
              final response = switch (cmd) {
                MultiroomCommands.mrZoneChannelGet =>
                  "${cmd.value}=CH${Random().nextInt(8)}",
                MultiroomCommands.mrMuteGet => "${cmd.value}=off",
                MultiroomCommands.mrVolGet =>
                  "${cmd.value}=${Random().nextInt(100)}",
                MultiroomCommands.mrBalGet =>
                  "${cmd.value}=${Random().nextInt(100)}",
                MultiroomCommands.mrEqGet =>
                  "${cmd.value}=${Random().nextInt(100)}",
                MultiroomCommands.mrExpModeGet => "${cmd.value}=OK",
                MultiroomCommands.mrZoneModeGet => "${cmd.value}=stereo",

                // TODO: Implement the other commands
                MultiroomCommands.mrParShow => "${cmd.value}=OK",
                MultiroomCommands.mrCfgShow => "${cmd.value}=OK",

                // SET COMMANDS
                _ => "${cmd.value}=OK",
              };

              await Future.delayed(Duration(milliseconds: 150));
              socket.writeln(response);
              logger.d(">>> ${response}");
            } catch (exception) {
              logger.d(exception.toString());
            }
          },
          onError: (exception) async {
            logger.e("${exception}\n\n\n");

            socket.destroy();

            await runServer(server);
          },
        );
      },
      onError: (exception) async {
        logger.e("${exception}\n\n\n");

        await runServer(server);
      },
    );
  } catch (exception) {
    logger.e("${exception}\n\n\n");

    await runServer(server);
  }
}

void main() async {
  try {
    final server = await ServerSocket.bind('0.0.0.0', port);

    logger.d("*** Server started --> waiting connections... ***");

    await runServer(server);
  } catch (exception) {
    logger.e(exception.toString());
  }
}
