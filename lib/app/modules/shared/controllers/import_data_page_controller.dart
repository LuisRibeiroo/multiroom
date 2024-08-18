import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signals/signals_flutter.dart';

import '../../../../injector.dart';
import '../../../core/enums/page_state.dart';
import '../../../core/interactor/controllers/base_controller.dart';
import '../../../core/interactor/repositories/settings_contract.dart';
import '../../../core/interactor/utils/hive_utils.dart';

class ImportDataPageController extends BaseController {
  ImportDataPageController() : super(InitialState()) {
    disposables.add(effect(() {
      isValidProjectId.value = code.value.length == 8;
    }));
  }

  final _settings = injector.get<SettingsContract>();

  final code = "".toSignal(debugLabel: "code");
  final isValidProjectId = false.toSignal(debugLabel: "isValidProjectId");

  Future<void> handleBarCode(String value) => _downloadAndUpdateFile(value);

  Future<void> onConfirmImport() => _downloadAndUpdateFile("MR-${code.value}");

  Future<void> _downloadAndUpdateFile(String projectId) async {
    try {
      if (projectId.length == 11 && projectId.startsWith("MR-")) {
        final response = await run<Response>(
          () => Dio().get(
            "https://multiroom.s3.sa-east-1.amazonaws.com/$projectId",
            onReceiveProgress: _showDownloadProgress,
            options: Options(
              responseType: ResponseType.bytes,
              validateStatus: (status) => (status ?? 501) < 500,
              followRedirects: false,
            ),
          ),
        );

        if ((response.statusCode ?? 500) >= 400) {
          setError(Exception("Código não encontrado"));
          return;
        }

        await HiveUtils.closeBox();

        final dir = await getApplicationDocumentsDirectory();
        final file = File("${dir.path}/${HiveUtils.boxName}.hive");
        final raf = file.openSync(mode: FileMode.write);

        // response.data is List<int> type
        raf.writeFromSync(response.data);
        await raf.close();

        final box = await HiveUtils.loadBox();
        _settings.updateReference(box);

        state.value = const SuccessState(data: null);
      } else {
        setError(Exception("Código inválido"));
      }
    } catch (exception) {
      if (exception is Exception) {
        setError(exception);
      } else {
        setError(Exception(exception));
      }
    }
  }

  void onChangeCode(String value) => code.value = value;

  void _showDownloadProgress(received, total) {
    if (total != -1) {
      // logger.d("Download state -> ${(received / total * 100).toStringAsFixed(0)}%");
    }
  }

  @override
  void dispose() {
    super.dispose();

    code.value = code.initialValue;
    isValidProjectId.value = isValidProjectId.initialValue;
  }
}
