import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:routefly/routefly.dart';
import 'package:signals/signals_flutter.dart';
import 'package:udp/udp.dart';

import '../../../../../injector.dart';
import '../../../../../routes.g.dart';
import '../../../../core/enums/device_type.dart';
import '../../../../core/enums/page_state.dart';
import '../../../../core/extensions/list_extensions.dart';
import '../../../../core/extensions/string_extensions.dart';
import '../../../../core/interactor/controllers/base_controller.dart';
import '../../../../core/interactor/controllers/device_monitor_controller.dart';
import '../../../../core/interactor/controllers/socket_mixin.dart';
import '../../../../core/interactor/repositories/settings_contract.dart';
import '../../../../core/models/device_model.dart';
import '../../../../core/models/project_model.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/datagram_data_parser.dart';
import '../../../../core/utils/mr_cmd_builder.dart';
import '../../../../core/utils/platform_checker.dart';
import '../models/network_device_model.dart';

class ScannerPageController extends BaseController with SocketMixin {
  ScannerPageController() : super(InitialState()) {
    disposables.addAll(
      [
        effect(() async {
          if (_isPageVisible.value && _monitor.hasStateChanges.value) {
            untracked(() async {
              projects.value = settings.projects;

              _monitor.ingestStateChanges();
            });
          }
        }),
      ],
    );
  }

  UDP? _udpServer;

  final settings = injector.get<SettingsContract>();
  final _monitor = injector.get<DeviceMonitorController>();
  final _isUdpListening = false.asSignal(debugLabel: "isUdpListening");

  final projects = listSignal<ProjectModel>([], debugLabel: "projects");
  final networkDevices = listSignal<NetworkDeviceModel>([], debugLabel: "networkDevices");
  final deviceType = NetworkDeviceType.undefined.asSignal(debugLabel: "deviceType");
  final projectName = "".asSignal(debugLabel: "projectName");
  final currentProject = ProjectModel.empty().asSignal(debugLabel: "currentProject");
  final hasDevices = false.asSignal(debugLabel: "hasDevices");

  final isMasterAvailable = true.asSignal(debugLabel: "isMasterAvailable");
  final slave1Available = true.asSignal(debugLabel: "slave1Available");
  final slave2Available = true.asSignal(debugLabel: "slave2Available");
  final hasAvailableSlots = false.asSignal(debugLabel: "hasAvailableSlots");
  final selectedDevice = NetworkDeviceModel.empty().asSignal(debugLabel: "selectedDevice");

  final _localDevices = listSignal(
    <DeviceModel>[],
    debugLabel: "localDevices",
  );

  final _isPageVisible = false.asSignal(debugLabel: "scannerPageVisible");

  void setPageVisible(bool visible) => _isPageVisible.value = visible;
  void startDeviceMonitor() => _monitor.startDeviceMonitor(
        callerName: runtimeType.toString(),
        cycleDuration: defaultScanDuration,
      );

  Future<void> init() async {
    projects.value = settings.projects;
    hasDevices.value = projects.value.expand((p) => p.devices).toList().isNotEmpty;

    disposables.addAll(
      [
        effect(() {
          hasAvailableSlots.value = currentProject.value.devices.length < 3;
          isMasterAvailable.value = currentProject.value.devices.isEmpty ||
              currentProject.value.devices.every((d) => d.type != DeviceType.master);
          slave1Available.value = isMasterAvailable.peek() == false &&
              currentProject.value.devices.where((d) => d.type == DeviceType.slave).isEmpty;
          slave2Available.value = slave1Available.peek() == false &&
              currentProject.value.devices.where((d) => d.type == DeviceType.slave).length == 1;

          if (hasAvailableSlots.value == false) {
            stopUdpServer();
          }
        }),
        effect(() async {
          // await _updateDevicesAvailabilityAndFirmware();
          _localDevices.value = projects.value.expand((p) => p.devices).toList();
        }),
        effect(() {
          if (_isUdpListening.value) {
            logger.i("UDP LISTENING ON --> ${_udpServer?.local.address?.address}:${_udpServer?.local.port?.value} ");
          } else {
            logger.i("UDP SERVER CLOSED");
          }
        }),
        effect(() {
          settings.saveProjects(projects.value);
          hasDevices.value = projects.value.expand((p) => p.devices).toList().isNotEmpty;
        }),
      ],
    );
  }

  void setSelectedDevice(NetworkDeviceModel device) => selectedDevice.value = device;

  Future<void> startUdpServer() async {
    if (PlatformChecker.isMobile) {
      await Permission.nearbyWifiDevices.request();
    }

    if (_isUdpListening.value) {
      return;
    }

    _monitor.stopDeviceMonitor(stopServer: true);

    try {
      _udpServer = await UDP.bind(
        Endpoint.unicast(
          InternetAddress.anyIPv4,
          port: const Port(4055),
        ),
      );

      _isUdpListening.value = true;

      _udpServer?.asStream().listen(
        (datagram) {
          if (datagram == null) {
            return;
          }

          try {
            final data = datagram.data;
            logger.i("UDP DATA --> $data | FROM ${datagram.address.address}:${datagram.port}");

            final (serialNumber, firmware, macAddress) = DatagramDataParser.getSerialMacAndFirmware(datagram.data);
            logger.i("MAC ADDRESS DATA --> $macAddress");

            // Ignore already added devices
            if (_localDevices.value.any((d) => d.serialNumber == serialNumber) ||
                networkDevices.any((d) => d.serialNumber == serialNumber)) {
              return;
            }

            networkDevices.add(
              NetworkDeviceModel(
                ip: datagram.address.address,
                serialNumber: serialNumber,
                firmware: firmware,
                macAddress: macAddress,
              ),
            );
          } catch (exception) {
            logger.e("Datagram parse error [${datagram.address.address}]-> $exception");
          }
        },
      );
    } catch (exception) {
      if (exception.toString().contains("Failed to create datagram socket")) {
        await startUdpServer();
      } else {
        logger.e(exception);
        setError(exception as Exception);
      }
    }
  }

  void stopUdpServer() {
    if (_udpServer?.closed == false) {
      _udpServer?.close();
    }

    _isUdpListening.value = false;
    startDeviceMonitor();
  }

  Computed<bool> get isProjectNameValid => computed(() => projectName.value.isNotNullOrEmpty);

  void onTapConfigDevice(DeviceModel device) {
    stopUdpServer();

    Routefly.push(routePaths.modules.configs.pages.deviceConfiguration, arguments: device).then(
      (_) async {
        await run(() async {
          projects.value = settings.projects;
          await Future.delayed(const Duration(milliseconds: 500));
        });
      },
    );
  }

  Future<void> onConfirmAddDevice(NetworkDeviceModel netDevice) async {
    final type = await _setDeviceType(
      netDevice.ip,
      netDevice.macAddress,
      DeviceType.fromString(deviceType.value.name.lettersOnly),
    );

    final newDevice = DeviceModel.builder(
      projectId: currentProject.value.id,
      projectName: currentProject.value.name,
      ip: netDevice.ip,
      serialNumber: netDevice.serialNumber,
      macAddress: netDevice.macAddress,
      version: netDevice.firmware,
      name: deviceType.value.readable,
      type: DeviceType.fromString(type),
    );

    _updateProject(newDevice);

    await Future.delayed(Durations.long2);
    onTapConfigDevice(newDevice);

    deviceType.value = deviceType.initialValue;
    if (networkDevices.any((n) => n.serialNumber == netDevice.serialNumber)) {
      networkDevices.removeWhere((d) => d.serialNumber == netDevice.serialNumber);
    }
  }

  void addProject() {
    final project = ProjectModel.builder(
      name: projectName.value,
    );

    projects.add(project);

    currentProject.value = project;
    projectName.value = projectName.initialValue;
  }

  void removeProject(ProjectModel project) {
    settings.removeProject(project.id);

    projectName.value = projectName.initialValue;
    currentProject.value = currentProject.initialValue;

    projects.value = settings.projects;
  }

  // Future<void> _updateDevicesAvailabilityAndFirmware() async {
  //   // TODO: Improve this to use UDP data to update info
  //   for (final proj in projects.value) {
  //     for (final d in proj.devices) {
  //       try {
  //         await restartSocket(ip: d.ip);
  //         final fw =
  //             MrCmdBuilder.parseResponse(await socketSender(MrCmdBuilder.firmwareVersion(macAddress: d.macAddress)));
  //         final formatted = "${fw.substring(0, 2)}.${fw.substring(2).padLeft(2, "0")}";

  //         final newDevices = proj.devices.withReplacement(
  //           (device) => device.serialNumber == d.serialNumber,
  //           d.copyWith(version: formatted.numbersOnly.isNotNullOrEmpty ? formatted : d.version),
  //         );

  //         projects.value.replaceWhere(
  //           (p) => p.id == proj.id,
  //           proj.copyWith(devices: newDevices),
  //         );

  //         devicesAvailability[d.serialNumber] = true;
  //       } catch (exception) {
  //         devicesAvailability[d.serialNumber] = false;
  //       }
  //     }
  //   }
  // }

  void _updateProject(DeviceModel newDevice) {
    currentProject.value = currentProject.peek().copyWith(devices: [...currentProject.peek().devices, newDevice]);

    final List<ProjectModel> newProjects = List.from(projects.peek());
    newProjects.replaceWhere((p) => p.id == currentProject.peek().id, currentProject.value);

    projects.value = newProjects;
  }

  Future<String> _setDeviceType(String ip, String macAddress, DeviceType type) async {
    try {
      await restartSocket(ip: ip);

      final ret = MrCmdBuilder.parseCompleteResponse(
        await socketSender(
          MrCmdBuilder.setExpansionMode(macAddress: macAddress, type: type),
        ),
      );

      if (ret.macAddress.toUpperCase() != macAddress.toUpperCase()) {
        throw Exception("Erro ao configurar dispositivo, tente novamente.");
      }

      final deviceMode = MrCmdBuilder.parseResponse(
        await socketSender(MrCmdBuilder.expansionMode(macAddress: macAddress)),
      );

      return deviceMode;
    } catch (exception) {
      logger.e(exception);
      setError(exception as Exception);

      rethrow;
    }
  }

  void _clearEmptyProjects() {
    final emptyProjects = projects.value = projects.value.where((p) => p.devices.isEmpty).toList();

    for (final p in emptyProjects) {
      settings.removeProject(p.id);
    }
  }

  @override
  void dispose() {
    super.dispose();
    mixinDispose();

    _clearEmptyProjects();
    stopUdpServer();

    _isUdpListening.value = _isUdpListening.initialValue;
    deviceType.value = deviceType.initialValue;
    projectName.value = projectName.initialValue;
    currentProject.value = currentProject.initialValue;

    isMasterAvailable.value = isMasterAvailable.initialValue;
    slave1Available.value = slave1Available.initialValue;
    slave2Available.value = slave2Available.initialValue;
    hasAvailableSlots.value = hasAvailableSlots.initialValue;

    projects.value = <ProjectModel>[];
    networkDevices.value = <NetworkDeviceModel>[];
  }
}
