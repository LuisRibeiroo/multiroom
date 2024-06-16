import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:routefly/routefly.dart';
import 'package:signals/signals_flutter.dart';

import '../../../../injector.dart';
import '../../../../routes.g.dart';
import '../../../core/enums/page_state.dart';
import '../../../core/extensions/string_extensions.dart';
import '../../../core/interactor/controllers/base_controller.dart';
import '../../../core/interactor/repositories/settings_contract.dart';
import '../../../core/models/device_model.dart';

class ConfigsPageController extends BaseController {
  ConfigsPageController() : super(InitialState()) {
    localDevices.value = settings.devices;

    disposables.add(
      effect(
        () {
          password.value;
          errorMessage.value = errorMessage.initialValue;
        },
      ),
    );
  }

  final settings = injector.get<SettingsContract>();

  final device = DeviceModel.empty().toSignal(debugLabel: "currentDevice");
  final localDevices = listSignal<DeviceModel>([], debugLabel: "localDevices");
  final password = "".toSignal(debugLabel: "password");
  final errorMessage = "".toSignal(debugLabel: "errorMessage");

  Future<void> init() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await [
        Permission.location,
        Permission.nearbyWifiDevices,
        Permission.locationWhenInUse,
      ].request();
    }
  }

  void onChangeActive(DeviceModel device, bool value) {
    localDevices[localDevices.indexOf(device)] = device.copyWith(active: value);
  }

  void onTapConfigDevice(DeviceModel device) {
    Routefly.push<bool?>(
      routePaths.configs.pages.deviceConfiguration,
      arguments: device,
    ).then(
      (_) => localDevices.value = settings.devices,
    );

    untracked(localDevices.clear);
  }

  void onTapAccess() {
    // state.value =
    //     test == password.value ? const SuccessState(data: null) : ErrorState(exception: Exception("Senha inválida"));

    // if (settings.technicianAccessHash == password.value.getMd5) {
    if ("123".getMd5 == password.value.getMd5) {
      state.value = const SuccessState(data: null);
    } else {
      errorMessage.value = "Senha inválida";
    }
  }

  @override
  void dispose() {
    super.dispose();

    localDevices.value = <DeviceModel>[];
    device.value = device.initialValue;
    password.value = password.initialValue;
    errorMessage.value = errorMessage.initialValue;
  }
}

/*
Configs Response
{EXP_MODE: MASTER, MODE1: STEREO, MODE2: MONO, MODE3: MONO, MODE4: STEREO, MODE5: STEREO, MODE6: STEREO, MODE7: STEREO, MODE8: MONO, VOL_MAX1L: 100[%], VOL_MAX1R: 100[%], VOL_MAX2L: 100[%], VOL_MAX2R: 100[%], VOL_MAX3L: 100[%], VOL_MAX3R: 100[%], VOL_MAX4L: 100[%], VOL_MAX4R: 100[%], VOL_MAX5L: 100[%], VOL_MAX5R: 100[%], VOL_MAX6L: 100[%], VOL_MAX6R: 100[%], VOL_MAX7L: 100[%], VOL_MAX7R: 100[%], VOL_MAX8L: 100[%], VOL_MAX8R: 100[%], GRP[1][1]: (null), GRP[1][2]: (null), GRP[1][3]: (null), GRP[1][4]: (null), GRP[1][5]: (null), GRP[1][6]: (null), GRP[1][7]: (null), GRP[1][8]: (null), GRP[1][9]: (null), GRP[1][10]: (null), GRP[1][11]: (null), GRP[1][12]: (null), GRP[1][13]: (null), GRP[1][14]: (null), GRP[1][15]: (null), GRP[1][16]: (null), GRP[2][1]: (null), GRP[2][2]: (null), GRP[2][3]: (null), GRP[2][4]: (null), GRP[2][5]: (null), GRP[2][6]: (null), GRP[2][7]: (null), GRP[2][8]: (null), GRP[2][9]: (null), GRP[2][10]: (null), GRP[2][11]: (null), GRP[2][12]: (null), GRP[2][13]: (null), GRP[2][14]: (null), GRP[2][15]: (null), GRP[2][16]: (null), GRP[3][1]: (null), GRP[3][2]: (null), GRP[3][3]: (null), GRP[3][4]: (null), GRP[3][5]: (null), GRP[3][6]: (null), GRP[3][7]: (null), GRP[3][8]: (null), GRP[3][9]: (null), GRP[3][10]: (null), GRP[3][11]: (null), GRP[3][12]: (null), GRP[3][13]: (null), GRP[3][14]: (null), GRP[3][15]: (null), GRP[3][16]: (null)}
*/