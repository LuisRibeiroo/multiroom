import 'package:flutter/material.dart';

import '../../../core/extensions/build_context_extensions.dart';
import '../../../core/extensions/number_extensions.dart';
import '../interactor/models/network_device_model.dart';

class NetworkDevicesBottomSheet extends StatelessWidget {
  const NetworkDevicesBottomSheet({
    super.key,
    required this.hasAvailableSlots,
    required this.networkDevices,
    required this.onTapDevice,
  });

  final bool hasAvailableSlots;
  final List<NetworkDeviceModel> networkDevices;
  final Function() onTapDevice;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            visible: hasAvailableSlots,
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
              child: networkDevices.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: CircularProgressIndicator(),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: networkDevices.length,
                      itemBuilder: (_, index) {
                        final netDevice = networkDevices[index];

                        return ListTile(
                          title: Text(netDevice.ip),
                          subtitle: Text(
                            "${netDevice.serialNumber} - Ver ${netDevice.firmware}",
                          ),
                          trailing: const Icon(Icons.add_circle_rounded),
                          onTap: onTapDevice,
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
