import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:signals/signals_flutter.dart';
import 'package:udp/udp.dart';

class UdpPage extends StatefulWidget {
  const UdpPage({super.key});

  @override
  State<UdpPage> createState() => _UdpPageState();
}

class _UdpPageState extends State<UdpPage> {
  final info = NetworkInfo();
  final _scrollController = ScrollController();

  final localIp = "".toSignal();
  final networkName = "".toSignal();
  final isServerRunning = false.toSignal();
  final serverPort = "65000".toSignal();
  final senderPort = "65000".toSignal();
  final receivedDataList = listSignal<String>([]);
  final sentDataList = listSignal<String>([]);
  final messageToSend = "Teste 123".toSignal();
  final maxServerTimeout = const Duration(seconds: 60);
  final currentTimer = 0.toSignal();

  UDP? udpServer;

  Future<void> _checkPermissions() async {
    await [
      Permission.location,
      Permission.nearbyWifiDevices,
      Permission.locationWhenInUse,
    ].request();
  }

  @override
  void initState() {
    super.initState();

    scheduleMicrotask(() async {
      _checkPermissions();

      localIp.value = await info.getWifiIP() ?? "Não encontrado";

      networkName.value = await info.getWifiName() ?? "Não encontrado";
    });
  }

  Future<void> _startServer() async {
    try {
      udpServer = await UDP.bind(
        Endpoint.loopback(
          port: Port(
            int.parse(serverPort.value),
          ),
        ),
      );

      isServerRunning.value = true;

      Timer.periodic(
        const Duration(seconds: 1),
        (timer) {
          if (isServerRunning.value == false) {
            timer.cancel();
            return;
          }

          currentTimer.value = timer.tick;

          if (currentTimer.value >= maxServerTimeout.inSeconds) {
            timer.cancel();
            udpServer?.close();
            isServerRunning.value = false;
            currentTimer.value = currentTimer.initialValue;
          }
        },
      );

      udpServer?.asStream(timeout: maxServerTimeout).listen((datagram) {
        final data = String.fromCharCodes(datagram?.data ?? <int>[]);

        debugPrint("Data received: $data");

        receivedDataList.add("[${receivedDataList.length + 1}] $data");

        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: Durations.medium3, curve: Curves.easeInOut);
      });

      debugPrint(
          ">>>>>> Listening on: ${udpServer?.local.address?.address}:${udpServer?.local.port?.value}");
    } catch (exception) {
      debugPrint(exception.toString());
    }
  }

  Future<void> _stopServer() async {
    udpServer?.close();
    isServerRunning.value = false;
    currentTimer.value = currentTimer.initialValue;
  }

  Future<void> _sendMessage() async {
    try {
      final sender = await UDP.bind(
        Endpoint.any(
          port: Port(
            int.parse(senderPort.value),
          ),
        ),
      );

      final dataLength = await sender.send(
        messageToSend.value.codeUnits,
        Endpoint.loopback(
          port: Port(
            int.parse(senderPort.value),
          ),
        ),
      );

      sender.close();

      debugPrint(
          "SENT [${senderPort.value}][$dataLength] -> ${messageToSend.value}");
    } catch (exception) {
      debugPrint(exception.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teste UDP'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        scrolledUnderElevation: 0,
      ),
      body: Watch(
        (_) => SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: LocalData(
                    networkName: networkName.value,
                    localIp: localIp.value,
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: Card.filled(
                    child: Watch(
                      (_) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            isThreeLine: true,
                            title: const Text('Servidor'),
                            subtitle: AnimatedSize(
                              duration: Durations.short4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(isServerRunning.value
                                      ? "Rodando"
                                      : "Parado"),
                                  Visibility(
                                    visible: isServerRunning.value,
                                    child: Text(
                                      "Tempo restante: ${maxServerTimeout.inSeconds - currentTimer.value}s",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            trailing: AnimatedSwitcher(
                              duration: Durations.short4,
                              child: IconButton(
                                key: ValueKey(isServerRunning.value),
                                icon: isServerRunning.value
                                    ? const Icon(Icons.stop_circle_rounded)
                                    : const Icon(
                                        Icons.play_circle_fill_rounded),
                                onPressed: () async {
                                  isServerRunning.value
                                      ? await _stopServer()
                                      : await _startServer();
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 18.0),
                            child: Column(
                              children: [
                                TextFormField(
                                  enabled: isServerRunning.value == false,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Porta',
                                  ),
                                  initialValue: serverPort.value,
                                  keyboardType: TextInputType.number,
                                  onChanged: serverPort.set,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Dados Recebidos",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          SizedBox(
                            height: 150,
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12.0),
                              controller: _scrollController,
                              itemCount: receivedDataList.length,
                              itemBuilder: (context, index) => Text(
                                receivedDataList[index],
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: Card.filled(
                    child: Watch(
                      (_) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: const Text('Cliente'),
                            trailing: AnimatedSwitcher(
                              duration: Durations.short4,
                              child: IconButton(
                                key: ValueKey(isServerRunning.value),
                                icon: const Icon(Icons.send_rounded),
                                onPressed: _sendMessage,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18.0, vertical: 12.0),
                            child: Column(
                              children: [
                                TextFormField(
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Porta',
                                  ),
                                  initialValue: senderPort.value,
                                  keyboardType: TextInputType.number,
                                  onChanged: senderPort.set,
                                  textInputAction: TextInputAction.next,
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Mensagem',
                                  ),
                                  initialValue: messageToSend.value,
                                  onChanged: messageToSend.set,
                                  textInputAction: TextInputAction.send,
                                  onFieldSubmitted: (_) => _sendMessage(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LocalData extends StatelessWidget {
  const LocalData({
    super.key,
    required this.networkName,
    required this.localIp,
  });

  final String networkName;
  final String localIp;

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      child: Column(
        children: [
          ListTile(
            title: const Text('Wi-fi'),
            subtitle: Text(networkName),
            trailing: IconButton(
              icon: const Icon(Icons.copy_rounded),
              onPressed: () async {
                await Clipboard.setData(
                  ClipboardData(text: networkName),
                );
              },
            ),
          ),
          const Divider(indent: 12, endIndent: 12),
          ListTile(
            title: const Text('IP local'),
            subtitle: Text(localIp),
            trailing: IconButton(
              icon: const Icon(Icons.copy_rounded),
              onPressed: () async {
                await Clipboard.setData(
                  ClipboardData(text: localIp),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
