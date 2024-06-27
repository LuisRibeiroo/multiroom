import 'dart:async';

import 'package:flutter/material.dart';
import 'package:routefly/routefly.dart';
import 'package:signals/signals_flutter.dart';

import '../../../../injector.dart';
import '../../../core/extensions/build_context_extensions.dart';
import '../../../core/extensions/number_extensions.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../interactor/controllers/scanner_page_controller.dart';
import '../interactor/models/network_device_model.dart';
import '../widgets/device_list_tile.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final _controller = injector.get<ScannerPageController>();

  void _showNetworkDevicesBottomSheet() {
    _controller.startUdpServer();

    context.showCustomModalBottomSheet(
      child: Watch(
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Dispositivos encontrados na rede",
                style: context.textTheme.titleLarge,
              ),
              12.asSpace,
              Visibility(
                visible: _controller.hasAvailableSlots.value == false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  child: PhysicalModel(
                    borderRadius: BorderRadius.circular(8),
                    color: context.colorScheme.inversePrimary,
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Já existem 3 dispositivos configurados. Para adicionar um novo, será necessário remover um dos existentes.",
                        style: context.textTheme.bodyLarge!.copyWith(color: context.colorScheme.onSurface),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
              Flexible(
                child: AnimatedSize(
                  duration: Durations.short4,
                  child: _controller.networkDevices.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.0),
                          child: CircularProgressIndicator(),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _controller.networkDevices.length,
                          itemBuilder: (_, index) {
                            final netDevice = _controller.networkDevices[index];

                            return ListTile(
                              title: Text(netDevice.ip),
                              subtitle: Text(
                                "${netDevice.serialNumber} - Ver ${netDevice.firmware}",
                              ),
                              trailing: const Icon(Icons.add_circle_rounded),
                              onTap: () {
                                Routefly.pop(context);

                                _showDeviceTypeSelectorBottomSheet();
                              },
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeviceTypeSelectorBottomSheet() {
    context.showCustomModalBottomSheet(
      child: Watch(
        (_) => TypeSelectionBottomSheet(
          netDevice: _controller.networkDevices.first,
          deviceType: _controller.deviceType.value,
          onChangeType: _controller.deviceType.set,
          onTapConfirm: _controller.onConfirmAddDevice,
          masterAvailable: _controller.isMasterAvailable.value,
          slave1Available: _controller.slave1Available.value,
          slave2Available: _controller.slave2Available.value,
        ),
      ),
    );
  }

  void _showProjectListBottomSheet() {
    context.showCustomModalBottomSheet(
      child: Watch(
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.group_work_rounded),
                  12.asSpace,
                  Text(
                    "Projetos",
                    style: context.textTheme.titleLarge,
                  ),
                ],
              ),
              18.asSpace,
              SizedBox(
                width: context.sizeOf.width / 1.5,
                child: AppButton(
                  type: ButtonType.secondary,
                  text: "Novo",
                  trailing: const Icon(Icons.add_rounded),
                  onPressed: () {
                    Routefly.pop(context);
                    _showAddProjectBottomSheet();
                  },
                ),
              ),
              24.asSpace,
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _controller.projects.length,
                  itemBuilder: (_, index) {
                    final current = _controller.projects[index];

                    return ListTile(
                      title: Text(current.name),
                      trailing: const Icon(Icons.arrow_forward_rounded),
                      onTap: () {
                        Routefly.pop(context);

                        _controller.currentProject.set(current);
                        _showNetworkDevicesBottomSheet();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddProjectBottomSheet() {
    context.showCustomModalBottomSheet(
      child: Watch(
        (_) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Novo projeto",
                style: context.textTheme.titleLarge,
              ),
              12.asSpace,
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Nome",
                  hintText: "Casa",
                ),
                initialValue: _controller.projectName.value,
                onChanged: _controller.projectName.set,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: AppButton(
                  text: "Adicionar",
                  trailing: const Icon(Icons.check_rounded),
                  onPressed: _controller.isProjectNameValid.value
                      ? () {
                          Routefly.pop(context);
                          _controller.addProject();
                          _showNetworkDevicesBottomSheet();
                        }
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    scheduleMicrotask(() async {
      await _controller.init();

      if (_controller.localDevices.isEmpty) {
        _showProjectListBottomSheet();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Watch(
      (_) => LoadingOverlay(
        state: _controller.state,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Acesso Técnico"),
            actions: [
              Visibility(
                visible: _controller.isUdpListening.value,
                child: IconButton(
                  icon: const Icon(Icons.cancel_rounded),
                  onPressed: _controller.stopUdpServer,
                ),
              ),
              Visibility(
                visible: _controller.isUdpListening.value,
                child: const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(),
                ),
              ),
              24.asSpace,
            ],
          ),
          body: Watch(
            (_) => Visibility(
              visible: _controller.localDevices.isEmpty,
              replacement: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _controller.localDevices.length,
                itemBuilder: (_, index) => Watch(
                  (_) => DeviceListTile(
                    device: _controller.localDevices[index],
                    onTapConfigDevice: _controller.onTapConfigDevice,
                  ),
                ),
              ),
              child: Center(
                key: const ValueKey("empty"),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.settings_input_antenna_rounded,
                      size: 80,
                    ),
                    Text(
                      'Nenhum dispositivo configurado',
                      style: context.textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            // onPressed: _showNetworkDevicesBottomSheet,
            onPressed: _showProjectListBottomSheet,
            child: const Icon(Icons.settings_input_antenna_rounded),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();

    _controller.dispose();
  }
}

class TypeSelectionBottomSheet extends StatelessWidget {
  const TypeSelectionBottomSheet({
    super.key,
    required this.netDevice,
    required this.deviceType,
    required this.onChangeType,
    required this.onTapConfirm,
    required this.masterAvailable,
    required this.slave1Available,
    required this.slave2Available,
  });

  final NetworkDeviceModel netDevice;
  final NetworkDeviceType deviceType;
  final Function(NetworkDeviceType) onChangeType;
  final Function(NetworkDeviceModel) onTapConfirm;
  final bool masterAvailable;
  final bool slave1Available;
  final bool slave2Available;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Modo",
          style: context.textTheme.titleLarge,
        ),
        12.asSpace,
        Wrap(
          spacing: 24,
          alignment: WrapAlignment.center,
          runAlignment: WrapAlignment.center,
          children: [
            ChoiceChip(
              label: Text(NetworkDeviceType.master.readable),
              selected: deviceType == NetworkDeviceType.master,
              onSelected: masterAvailable ? (_) => onChangeType(NetworkDeviceType.master) : null,
            ),
            ChoiceChip(
              label: Text(NetworkDeviceType.slave1.readable),
              selected: deviceType == NetworkDeviceType.slave1,
              onSelected: slave1Available ? (_) => onChangeType(NetworkDeviceType.slave1) : null,
            ),
            ChoiceChip(
              label: Text(NetworkDeviceType.slave2.readable),
              selected: deviceType == NetworkDeviceType.slave2,
              onSelected: slave2Available ? (_) => onChangeType(NetworkDeviceType.slave2) : null,
            ),
          ],
        ),
        24.asSpace,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: AppButton(
            leading: const Icon(Icons.add_rounded),
            text: "Adicionar",
            onPressed: deviceType != NetworkDeviceType.undefined
                ? () {
                    Routefly.pop(context);
                    onTapConfirm(netDevice);
                  }
                : null,
          ),
        ),
        24.asSpace,
      ],
    );
  }
}
