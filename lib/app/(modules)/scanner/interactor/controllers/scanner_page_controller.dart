import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:signals/signals_flutter.dart';
import 'package:udp/udp.dart';

import '../../../../core/enums/device_type.dart';
import '../../../../core/enums/page_state.dart';
import '../../../../core/extensions/socket_extensions.dart';
import '../../../../core/extensions/stream_iterator_extensions.dart';
import '../../../../core/interactor/controllers/base_controller.dart';
import '../../../devices/interactor/utils/multiroom_command_builder.dart';
import '../models/technician_device_model.dart';

class ScannerPageController extends BaseController {
  ScannerPageController() : super(InitialState());

  late UDP udpServer;

  final isUdpListening = false.toSignal(debugLabel: "isServerListening", autoDispose: true);
  final devicesList = listSignal<TechnicianDeviceModel>([], debugLabel: "devicesList", autoDispose: true);

  Future<void> init() async {
    udpServer = await UDP.bind(
      Endpoint.unicast(
        InternetAddress.anyIPv4,
        port: const Port(4055),
      ),
    );

    try {
      isUdpListening.value = true;
      udpServer.asStream().listen((datagram) {
        if (datagram == null) {
          return;
        }

        final data = String.fromCharCodes(datagram.data);

        logger.i("UDP DATA --> $data | FROM ${datagram.address.address}:${datagram.port}");

        _addDevice(ip: datagram.address.address, data: data);
      });

      await Future.delayed(const Duration(seconds: 2));

      for (int i = 0; i < 10; i++) {
        await Future.delayed(
          const Duration(seconds: 1),
          () => devicesList.add(
            TechnicianDeviceModel(
              serialNumber: "${i + 1}",
              ip: "192.168.0.${i + 1}",
              version: "1.0",
              type: DeviceType.master,
            ),
          ),
        );
      }
    } catch (exception) {
      logger.e(exception);
      setError(exception as Exception);
    }

    effect(() {
      if (isUdpListening.value) {
        logger.i("UDP LISTENING ON --> ${udpServer.local.address?.address}:${udpServer.local.port?.value} ");
      } else {
        logger.i("UDP SERVER CLOSED");
      }
    });
  }

  void onChangeActive(TechnicianDeviceModel device, bool value) {
    devicesList[devicesList.indexOf(device)] = device.copyWith(active: value);
  }

  void onChangeType(TechnicianDeviceModel device, String value) {
    devicesList[devicesList.indexOf(device)] = device.copyWith(type: DeviceType.fromString(value));
  }

  Future<void> _addDevice({required String ip, required String data}) async {
    final mode = await _getDeviceMode(ip);
    String serialNumber = "";
    String firmware = "";

    switch (jsonDecode(data)) {
      case {"serialNumber": final value}:
        serialNumber = value;

      case {"fwVersion": final value}:
        firmware = value;
    }

    devicesList.add(
      TechnicianDeviceModel(
        serialNumber: serialNumber,
        ip: ip,
        active: true,
        masterName: "",
        version: firmware,
        type: DeviceType.fromString(mode),
      ),
    );
  }

  Future<String> _getDeviceMode(String ip) async {
    final Socket socket;

    try {
      socket = await run(
        () => Socket.connect(
          ip,
          4998,
          timeout: const Duration(seconds: 2),
        ),
      );

      final streamIterator = StreamIterator(socket);

      socket.writeLog(MultiroomCommandBuilder.expansionMode);
      final deviceMode = MultiroomCommandBuilder.parseResponse(await streamIterator.readSync());

      return deviceMode;
    } catch (exception) {
      logger.e(exception);
      setError(exception as Exception);

      rethrow;
    }
  }

  void dispose() {
    udpServer.close();
  }
}
