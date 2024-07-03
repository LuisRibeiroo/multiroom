import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signals/signals_flutter.dart';

import '../../../../injector.dart';
import '../../../core/enums/page_state.dart';
import '../../../core/extensions/string_extensions.dart';
import '../../../core/interactor/controllers/base_controller.dart';
import '../../../core/interactor/repositories/settings_contract.dart';
import '../../../core/interactor/utils/hive_utils.dart';

class OptionsBottomSheetController extends BaseController {
  OptionsBottomSheetController() : super(InitialState()) {
    showShareOption.value = settings.projects.isNotEmpty;
    showTechAccessOption.value = settings.projects.isNotEmpty;

    disposables.addAll([
      effect(
        () {
          password.value;
          errorMessage.value = errorMessage.initialValue;
        },
      ),
    ]);
  }

  final settings = injector.get<SettingsContract>();
  final password = "".toSignal(debugLabel: "password");
  final errorMessage = "".toSignal(debugLabel: "errorMessage");
  final isPasswordVisible = false.toSignal(debugLabel: "isPasswordVisible");

  final showShareOption = false.toSignal(debugLabel: "showShareOption");
  final showTechAccessOption = false.toSignal(debugLabel: "showTechAccessOption");

  bool onTapAccess() {
    /// !Control@061
    if (settings.technicianAccessHash == password.value.getMd5) {
      // if ("123".getMd5 == password.value.getMd5) {
      // state.value = const SuccessState(data: "techAccess");
      isPasswordVisible.value = false;
      return true;
    } else {
      errorMessage.value = "Senha inválida";
      return false;
    }
  }

  void onTogglePassword() => isPasswordVisible.value = !isPasswordVisible.value;

  Future<String> onShareProject({required Signal<PageState> pageState}) async {
    try {
      pageState.value = LoadingState();

      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/${HiveUtils.boxName}.hive");
      final data = file.readAsBytesSync();
      final base64Data = base64Encode(data);
      final info = await DeviceInfoPlugin().deviceInfo;
      final deviceHash = info.data["id"].toString().toProjectId;

      final response = await Dio().post(
        "https://9uodgvwql2.execute-api.sa-east-1.amazonaws.com/multiroomprofile/upload",
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
        data: {
          "content": base64Data,
          "filename": deviceHash,
        },
      );

      if (response.statusCode != 200) {
        logger.e("File Upload error --> $response");
        throw Exception("Erro ao fazer upload do arquivo, tente novamente");
      }

      final body = jsonDecode(response.data["body"]);
      final url = body["fileUrl"];

      pageState.value = InitialState();
      logger.d("RESPONSE --> $url");

      return deviceHash;
    } catch (exception) {
      if (exception is Exception) {
        pageState.value = ErrorState(exception: exception);
      } else {
        pageState.value = ErrorState(exception: Exception(exception));
      }

      return "";
    }
  }

  @override
  void dispose() {
    super.dispose();

    password.value = password.initialValue;
    errorMessage.value = errorMessage.initialValue;
    isPasswordVisible.value = isPasswordVisible.initialValue;
    showShareOption.value = showShareOption.initialValue;
  }
}
