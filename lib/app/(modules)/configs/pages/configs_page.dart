import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../../../../injector.dart';
import '../../../core/extensions/build_context_extensions.dart';
import '../../../core/extensions/number_extensions.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../../scanner/widgets/device_list_tile.dart';
import '../controllers/configs_page_controller.dart';
import '../widgets/no_devices_widget.dart';
import '../../(shared)/pages/options_bottom_sheet.dart';

class ConfigsPage extends StatefulWidget {
  const ConfigsPage({super.key});

  @override
  State<ConfigsPage> createState() => _ConfigsPageState();
}

class _ConfigsPageState extends State<ConfigsPage> {
  final _controller = injector.get<ConfigsPageController>();

  @override
  Widget build(BuildContext context) {
    return Watch(
      (_) => LoadingOverlay(
        state: _controller.state,
        child: Scaffold(
          appBar: AppBar(
            leading: Image.asset("assets/logo.png"),
            title: const Text("Configurações"),
            actions: [
              Visibility(
                visible: _controller.localDevices.isNotEmpty,
                child: IconButton(
                  onPressed: () => OptionsMenu.showOptionsBottomSheet(context),
                  icon: const Icon(Icons.menu_rounded),
                ),
              ),
            ],
          ),
          body: Visibility(
            visible: _controller.localDevices.isEmpty,
            replacement: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _controller.localDevices.length,
              itemBuilder: (_, index) => Watch(
                (_) => DeviceListTile(
                  device: _controller.localDevices[index],
                  onChangeActive: _controller.onChangeActive,
                  onTapConfigDevice: (d) => OptionsMenu.showTechBottomSheet(context, device: d),
                ),
              ),
            ),
            child: const NoDevicesWidget(),
          ),
          floatingActionButton: _controller.localDevices.isEmpty
              ? FloatingActionButton.extended(
                  icon: const Icon(Icons.settings_input_antenna_rounded),
                  label: const Text("Iniciar configuração"),
                  onPressed: () => OptionsMenu.showOptionsBottomSheet(context),
                )
              : null,
        ),
      ),
    );
  }
}

class TechAccessBottomSheet extends StatelessWidget {
  const TechAccessBottomSheet({
    super.key,
    required this.errorMessage,
    required this.onChangePassword,
    required this.onTapAccess,
    required this.onTapConfigDevice,
  });

  final String errorMessage;
  final Function(String) onChangePassword;
  final Function() onTapAccess;
  final Function()? onTapConfigDevice;

  @override
  Widget build(BuildContext context) {
    return Watch(
      (_) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Acesso técnico",
              style: context.textTheme.headlineSmall,
            ),
            8.asSpace,
            TextFormField(
              obscureText: true,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Senha',
                errorText: errorMessage,
              ),
              onChanged: onChangePassword,
            ),
            12.asSpace,
            ElevatedButton(
              onPressed: onTapConfigDevice ?? onTapAccess,
              child: const Text("Acessar"),
            ),
          ],
        ),
      ),
    );
  }
}
