import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:signals/signals_flutter.dart';
import 'package:toastification/toastification.dart';

import '../../../../injector.dart';
import '../../../core/enums/page_state.dart';
import '../../../core/extensions/build_context_extensions.dart';
import '../../../core/extensions/number_extensions.dart';
import '../../../core/extensions/text_input_formatter_extensions.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../controllers/import_data_page_controller.dart';
import '../widgets/camera_scan.dart';

class ImportDataPage extends StatefulWidget {
  const ImportDataPage({super.key});

  @override
  State<ImportDataPage> createState() => _ImportDataPageState();
}

class _ImportDataPageState extends State<ImportDataPage> with WidgetsBindingObserver {
  final _controller = injector.get<ImportDataPageController>();

  @override
  void initState() {
    super.initState();

    _controller.disposables.add(
      effect(
        () {
          if (_controller.state.value is SuccessState) {
            toastification.show(
              type: ToastificationType.success,
              style: ToastificationStyle.minimal,
              autoCloseDuration: const Duration(seconds: 5),
              title: const Text("Sucesso!"),
              description: const Text("Todos os dados foram importados com sucesso"),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Watch(
      (_) => LoadingOverlay(
        state: _controller.state,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Importar projeto"),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.link_rounded,
                          size: 36,
                        ),
                        8.asSpace,
                        Flexible(
                          child: Text(
                            "Insira o código MR",
                            style: context.textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: TextFormField(
                      onChanged: _controller.onChangeCode,
                      inputFormatters: TextInputFormatterExt.upperCase()
                        ..addAll(
                          [
                            FilteringTextInputFormatter.deny(
                              RegExp("MR-"),
                            ),
                            LengthLimitingTextInputFormatter(8),
                          ],
                        ),
                      keyboardType: TextInputType.text,
                      maxLength: 8,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            "MR-",
                            style: context.textTheme.titleLarge!.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  12.asSpace,
                  SizedBox(
                    width: context.sizeOf.width / 1.5,
                    child: AppButton(
                      text: "Importar",
                      trailing: const Icon(Icons.cloud_download_rounded),
                      onPressed: _controller.isValidProjectId.value
                          ? () {
                              SystemChannels.textInput.invokeMethod('TextInput.hide');
                              FocusScope.of(context).unfocus();

                              _controller.onConfirmImport();
                            }
                          : null,
                    ),
                  ),
                  Visibility(
                    visible: Platform.isIOS || Platform.isAndroid,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: CameraScan(
                        onDetectBarCode: _controller.handleBarCode,
                      ),
                    ),
                  ),
                  24.asSpace,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }
}
