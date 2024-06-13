import 'dart:async';
import 'dart:io';

import 'package:signals/signals_flutter.dart';
import 'package:udp/udp.dart';

import '../../../../core/enums/device_type.dart';
import '../../../../core/enums/page_state.dart';
import '../../../../core/extensions/socket_extensions.dart';
import '../../../../core/extensions/stream_iterator_extensions.dart';
import '../../../../core/extensions/string_extensions.dart';
import '../../../../core/interactor/controllers/base_controller.dart';
import '../../../../core/models/device_model.dart';
import '../../../../core/utils/datagram_data_parser.dart';
import '../../../../core/utils/multiroom_command_builder.dart';
import '../models/network_device_model.dart';

class ScannerPageController extends BaseController {
  ScannerPageController() : super(InitialState());

  late UDP udpServer;

  final isUdpListening = false.toSignal(debugLabel: "isUdpListening");
  final localDevices = listSignal<DeviceModel>([], debugLabel: "localDevices");
  final networkDevices = listSignal<NetworkDeviceModel>([], debugLabel: "networkDevices");
  final deviceType = NetworkDeviceType.undefined.toSignal(debugLabel: "deviceType");

  final isMasterAvailable = true.toSignal(debugLabel: "isMasterAvailable");
  final slave1Available = true.toSignal(debugLabel: "slave1Available");
  final slave2Available = true.toSignal(debugLabel: "slave2Available");

  Future<void> init() async {
    _startUdpServer();

    disposables.addAll(
      [
        isMasterAvailable.call,
        effect(() {
          isMasterAvailable.value = localDevices.every((d) => d.type != DeviceType.master);
          slave1Available.value = localDevices.where((d) => d.type == DeviceType.slave).isEmpty;
          slave2Available.value = localDevices.where((d) => d.type == DeviceType.slave).length < 2;
        }),
      ],
    );
  }

  Future<void> _startUdpServer() async {
    disposables.add(
      effect(() {
        if (isUdpListening.value) {
          logger.i("UDP LISTENING ON --> ${udpServer.local.address?.address}:${udpServer.local.port?.value} ");
        } else {
          logger.i("UDP SERVER CLOSED");
        }
      }),
    );

    try {
      udpServer = await UDP.bind(
        Endpoint.unicast(
          InternetAddress.anyIPv4,
          port: const Port(4055),
        ),
      );

      isUdpListening.value = true;
      udpServer.asStream().listen(
        (datagram) {
          if (datagram == null) {
            return;
          }

          final data = String.fromCharCodes(datagram.data);

          logger.i("UDP DATA --> $data | FROM ${datagram.address.address}:${datagram.port}");

          final (serialNumber, firmware) = DatagramDataParser.getSerialAndFirmware(data);

          networkDevices.add(
            NetworkDeviceModel(
              ip: datagram.address.address,
              serialNumber: serialNumber,
              firmware: firmware,
            ),
          );
        },
      );

      for (int i = 0; i < 10; i++) {
        await Future.delayed(
          const Duration(seconds: 1),
          () => networkDevices.add(
            NetworkDeviceModel(
              ip: "192.168.0.${i + 1}",
              serialNumber: "123456-$i",
              firmware: "1.0",
            ),
          ),
        );
      }

      // await Future.delayed(
      //   const Duration(seconds: 2),
      //   () => networkDevices.add(
      //     const NetworkDeviceModel(
      //       ip: "192.188.0.1",
      //       serialNumber: "123456",
      //       firmware: "1.0",
      //     ),
      //   ),
      // );
      // localDevices.add(
      //   DeviceModel.builder(
      //     serialNumber: Random().nextInt(99999).toString(),
      //     name: "Master 1",
      //     ip: "192.168.0.1",
      //     version: "1.0",
      //     type: DeviceType.master,
      //   ),
      // );
    } catch (exception) {
      logger.e(exception);
      setError(exception as Exception);
    }
  }

  void onChangeActive(DeviceModel device, bool value) {
    localDevices[localDevices.indexOf(device)] = device.copyWith(active: value);
  }

  void onChangeType(DeviceModel device, String value) {
    localDevices[localDevices.indexOf(device)] = device.copyWith(type: DeviceType.fromString(value));
  }

  Future<void> onConfirmAddDevice(NetworkDeviceModel netDevice) async {
    // final deviceMode = await _setDeviceMode(
    //   netDevice.ip,
    //   DeviceType.fromString(deviceType.value.name.lettersOnly),
    // );

    localDevices.add(
      DeviceModel.builder(
        ip: netDevice.ip,
        serialNumber: netDevice.serialNumber,
        version: netDevice.firmware,
        name: deviceType.value.readable,
        type: DeviceType.fromString(deviceType.value.name.lettersOnly),
      ),
    );

    deviceType.value = deviceType.initialValue;
  }

  Future<String> _setDeviceMode(String ip, DeviceType type) async {
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

      socket.writeLog(MultiroomCommandBuilder.setExpansionMode(type: type));
      final response = MultiroomCommandBuilder.parseResponse(await streamIterator.readSync());

      if (response.contains("OK") == false) {
        throw Exception("Erro ao configurar dispositivo, tente novamente.");
      }

      socket.writeLog(MultiroomCommandBuilder.expansionMode);
      final deviceMode = MultiroomCommandBuilder.parseResponse(await streamIterator.readSync());

      return deviceMode;
    } catch (exception) {
      logger.e(exception);
      setError(exception as Exception);

      rethrow;
    }
  }

  @override
  void dispose() {
    super.dispose();

    udpServer.closed ? null : udpServer.close();
    isUdpListening.value = isUdpListening.initialValue;
    deviceType.value = deviceType.initialValue;

    localDevices.value = <DeviceModel>[];
    networkDevices.value = <NetworkDeviceModel>[];
  }
}
