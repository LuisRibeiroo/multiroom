import 'dart:async';

import 'package:flutter/material.dart';
import 'package:routefly/routefly.dart';
import 'package:signals/signals_flutter.dart';

import '../../../../../injector.dart';
import '../../../../../routes.g.dart';
import '../../../../core/enums/page_state.dart';
import '../../../../core/extensions/build_context_extensions.dart';
import '../../../../core/extensions/number_extensions.dart';
import '../../../devices/ui/pages/device_demo_page.dart';
import '../../interactor/controllers/home_page_controller.dart';
import '../widgets/no_devices_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = injector.get<HomePageController>();

  void _openBottomSheet() {
    context.showCustomModalBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.settings_rounded),
            title: const Text("Acesso Técnico"),
            onTap: () {
              Routefly.pop(context);
              context.showCustomModalBottomSheet(
                child: Watch(
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
                            errorText: _controller.errorMessage.value,
                          ),
                          onChanged: _controller.password.set,
                        ),
                        12.asSpace,
                        ElevatedButton(
                          onPressed: _controller.onTapAccess,
                          child: const Text("Acessar"),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text("Sobre"),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    scheduleMicrotask(() async {
      await _controller.init();
    });

    effect(() {
      if (_controller.state.value is SuccessState) {
        _controller.errorMessage.value = "";
        _controller.state.value = InitialState();

        Routefly.pop(context);
        Routefly.pushNavigate(routePaths.scanner.ui.pages.scanner);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Watch(
      (_) => Scaffold(
        appBar: AppBar(
          leading: Image.asset("assets/logo.png"),
          actions: [
            Visibility(
              child: IconButton(
                onPressed: _openBottomSheet,
                icon: const Icon(Icons.menu_rounded),
              ),
            ),
          ],
        ),
        body: Visibility(
          visible: _controller.localDevices.isEmpty,
          replacement: const DeviceDemoPage(),
          child: const NoDevicesWidget(),
        ),
        floatingActionButton: _controller.localDevices.isEmpty
            ? FloatingActionButton.extended(
                icon: const Icon(Icons.settings_input_antenna_rounded),
                label: const Text("Iniciar configuração"),
                onPressed: _openBottomSheet,
              )
            : null,
      ),
    );
  }
}
