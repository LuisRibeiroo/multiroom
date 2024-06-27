import 'dart:async';
import 'dart:io';

import 'package:routefly/routefly.dart';
import 'package:signals/signals_flutter.dart';
import 'package:udp/udp.dart';

import '../../../../../injector.dart';
import '../../../../../routes.g.dart';
import '../../../../core/enums/device_type.dart';
import '../../../../core/enums/page_state.dart';
import '../../../../core/extensions/socket_extensions.dart';
import '../../../../core/extensions/stream_iterator_extensions.dart';
import '../../../../core/extensions/string_extensions.dart';
import '../../../../core/interactor/controllers/base_controller.dart';
import '../../../../core/interactor/repositories/settings_contract.dart';
import '../../../../core/models/device_model.dart';
import '../../../../core/models/project_model.dart';
import '../../../../core/utils/datagram_data_parser.dart';
import '../../../../core/utils/mr_cmd_builder.dart';
import '../models/network_device_model.dart';

class ScannerPageController extends BaseController {
  ScannerPageController() : super(InitialState());

  UDP? _udpServer;

  final settings = injector.get<SettingsContract>();

  final isUdpListening = false.toSignal(debugLabel: "isUdpListening");
  final projects = listSignal<ProjectModel>([], debugLabel: "projects");
  final localDevices = listSignal<DeviceModel>([], debugLabel: "localDevices");
  final networkDevices = listSignal<NetworkDeviceModel>([], debugLabel: "networkDevices");
  final deviceType = NetworkDeviceType.undefined.toSignal(debugLabel: "deviceType");
  final projectName = "".toSignal(debugLabel: "projectName");
  final currentProject = ProjectModel.empty().toSignal(debugLabel: "currentProject");

  final isMasterAvailable = true.toSignal(debugLabel: "isMasterAvailable");
  final slave1Available = true.toSignal(debugLabel: "slave1Available");
  final slave2Available = true.toSignal(debugLabel: "slave2Available");
  final hasAvailableSlots = false.toSignal(debugLabel: "hasAvailableSlots");

  Future<void> init() async {
    localDevices.value = settings.devices;
    projects.value = settings.projects;

    disposables.addAll(
      [
        effect(() {
          hasAvailableSlots.value = localDevices.length < 3;
          isMasterAvailable.value = localDevices.isEmpty && localDevices.every((d) => d.type != DeviceType.master);
          slave1Available.value =
              isMasterAvailable.peek() == false && localDevices.where((d) => d.type == DeviceType.slave).isEmpty;
          slave2Available.value =
              slave1Available.peek() == false && localDevices.where((d) => d.type == DeviceType.slave).length == 1;

          if (hasAvailableSlots.value == false) {
            stopUdpServer();
          }
        }),
        effect(() {
          if (isUdpListening.value) {
            logger.i("UDP LISTENING ON --> ${_udpServer?.local.address?.address}:${_udpServer?.local.port?.value} ");
          } else {
            logger.i("UDP SERVER CLOSED");
          }
        }),
        effect(() {
          settings.saveDevices(localDevices.value);
        }),
        effect(() {
          settings.saveProjects(projects.value);
        }),
      ],
    );
  }

  Future<void> startUdpServer() async {
    if (isUdpListening.value) {
      return;
    }

    try {
      _udpServer = await UDP.bind(
        Endpoint.unicast(
          InternetAddress.anyIPv4,
          port: const Port(4055),
        ),
      );

      isUdpListening.value = true;

      _udpServer?.asStream().listen(
        (datagram) {
          if (datagram == null) {
            return;
          }

          try {
            final data = datagram.data;
            logger.i("UDP DATA --> $data | FROM ${datagram.address.address}:${datagram.port}");

            final (serialNumber, firmware) = DatagramDataParser.getSerialAndFirmware(datagram.data);

            // Ignore already added devices
            if (localDevices.any((d) => d.serialNumber == serialNumber) ||
                networkDevices.any((d) => d.serialNumber == serialNumber)) {
              return;
            }

            networkDevices.add(
              NetworkDeviceModel(
                ip: datagram.address.address,
                serialNumber: serialNumber,
                firmware: firmware,
              ),
            );
          } catch (exception) {
            logger.e("Datagram parse error [${datagram.address.address}]-> $exception");
          }
        },
      );

      for (int i = 0; i < 5; i++) {
        networkDevices.add(
          NetworkDeviceModel(
            ip: "192.168.0.${i + 1}",
            serialNumber: "MR-123456-00$i",
            firmware: "1.0",
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
    } catch (exception) {
      logger.e(exception);
      setError(exception as Exception);
    }
  }

  void stopUdpServer() {
    if (_udpServer?.closed == false) {
      _udpServer?.close();
    }

    isUdpListening.value = false;
  }

  Computed<bool> get isProjectNameValid => computed(() => projectName.value.isNotNullOrEmpty);

  void onTapConfigDevice(DeviceModel device) {
    stopUdpServer();

    Routefly.push(routePaths.modules.configs.pages.deviceConfiguration, arguments: device).then(
      (_) async {
        if (localDevices.peek() != settings.devices) {
          localDevices.value = settings.devices;
        }
        if (projects.peek() != settings.projects) {
          projects.value = settings.projects;
        }
      },
    );
  }

  Future<void> onConfirmAddDevice(NetworkDeviceModel netDevice) async {
    // final type = await _setDeviceType(
    //   netDevice.ip,
    //   DeviceType.fromString(deviceType.value.name.lettersOnly),
    // );

    final newDevice = DeviceModel.builder(
      projectId: currentProject.value.id,
      projectName: currentProject.value.name,
      ip: netDevice.ip,
      serialNumber: netDevice.serialNumber,
      version: netDevice.firmware,
      name: deviceType.value.readable,
      type: DeviceType.fromString(deviceType.value.name.lettersOnly),
      // type: DeviceType.fromString(type),
    );

    localDevices.add(newDevice);
    onTapConfigDevice(newDevice);

    deviceType.value = deviceType.initialValue;
    networkDevices.removeWhere((d) => d.serialNumber == netDevice.serialNumber);
  }

  void addProject() {
    final project = ProjectModel.builder(
      name: projectName.value,
    );

    projects.add(project);

    currentProject.value = project;
    projectName.value = projectName.initialValue;
  }

  Future<String> _setDeviceType(String ip, DeviceType type) async {
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

      socket.writeLog(MrCmdBuilder.setExpansionMode(type: type));
      final response = MrCmdBuilder.parseResponse(await streamIterator.readSync());

      if (response.contains("OK") == false) {
        throw Exception("Erro ao configurar dispositivo, tente novamente.");
      }

      socket.writeLog(MrCmdBuilder.expansionMode);
      final deviceMode = MrCmdBuilder.parseResponse(await streamIterator.readSync());

      socket.close().ignore();

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

    stopUdpServer();
    isUdpListening.value = isUdpListening.initialValue;
    deviceType.value = deviceType.initialValue;
    projectName.value = projectName.initialValue;
    currentProject.value = currentProject.initialValue;

    isMasterAvailable.value = isMasterAvailable.initialValue;
    slave1Available.value = slave1Available.initialValue;
    slave2Available.value = slave2Available.initialValue;
    hasAvailableSlots.value = hasAvailableSlots.initialValue;

    projects.value = <ProjectModel>[];
    localDevices.value = <DeviceModel>[];
    networkDevices.value = <NetworkDeviceModel>[];
  }
}