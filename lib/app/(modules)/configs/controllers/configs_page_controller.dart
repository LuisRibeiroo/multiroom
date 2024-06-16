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

    localDevices.add(
      DeviceModel.builder(
        serialNumber: "MR01234-0933",
        name: "Master 1",
        ip: "192.168.0.1",
        version: "3.2",
      ),
    );

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

/*
Params Response
{SWM1L: (null), SWM1R: (null), SWM2L: (null), SWM2R: (null), SWM3L: (null), SWM3R: (null), SWM4L: (null), SWM4R: (null), SWM5L: (null), SWM5R: (null), SWM6L: (null), SWM6R: (null), SWM7L: (null), SWM7R: (null), SWM8L: (null), SWM8R: (null), SWS1: Z1, SWS2: Z1, SWS3: Z4, SWS4: Z4, SWS5: Z5, SWS6: Z6, SWS7: Z7, SWS8: Z8, VG1L: 47[%], VG1R: 47[%], VG2L: 100[%], VG2R: 100[%], VG3L: 50[%], VG3R: 50[%], VG4L: 100[%], VG4R: 100[%], VG5L: 100[%], VG5R: 100[%], VG6L: 100[%], VG6R: 100[%], VG7L: 100[%], VG7R: 100[%], VG8L: 100[%], VG8R: 100[%], EQ1L_32Hz: 80[0.1dB], EQ1R_32Hz: 80[0.1dB], EQ1L_64Hz: 60[0.1dB], EQ1R_64Hz: 60[0.1dB], EQ1L_125Hz: 60[0.1dB], EQ1R_125Hz: 60[0.1dB], EQ1L_250Hz: 60[0.1dB], EQ1R_250Hz: 60[0.1dB], EQ1L_500Hz: 60[0.1dB], EQ1R_500Hz: 60[0.1dB], EQ1L_1KHz: 60[0.1dB], EQ1R_1KHz: 60[0.1dB], EQ1L_2KHz: 60[0.1dB], EQ1R_2KHz: 60[0.1dB], EQ1L_4KHz: 60[0.1dB], EQ1R_4KHz: 60[0.1dB], EQ1L_8KHz: 60[0.1dB], EQ1R_8KHz: 60[0.1dB], EQ1L_16KHz: 60[0.1dB], EQ1R_16KHz: 60[0.1dB], EQ2L_32Hz: 1[0.1dB], EQ2R_32Hz: 1[0.1dB], EQ2L_64Hz: 1[0.1dB], EQ2R_64Hz: 1[0.1dB], EQ2L_125Hz: 1[0.1dB], EQ2R_125Hz: 1[0.1dB], EQ2L_250Hz: 1[0.1dB], EQ2R_250Hz: 1[0.1dB], EQ2L_500Hz: 1[0.1dB], EQ2R_500Hz: 1[0.1dB], EQ2L_1KHz: 1[0.1dB], EQ2R_1KHz: 1[0.1dB], EQ2L_2KHz: 1[0.1dB], EQ2R_2KHz: 1[0.1dB], EQ2L_4KHz: 1[0.1dB], EQ2R_4KHz: 1[0.1dB], EQ2L_8KHz: 1[0.1dB], EQ2R_8KHz: 1[0.1dB], EQ2L_16KHz: 1[0.1dB], EQ2R_16KHz: 1[0.1dB], EQ3L_32Hz: 1[0.1dB], EQ3R_32Hz: 1[0.1dB], EQ3L_64Hz: 1[0.1dB], EQ3R_64Hz: 1[0.1dB], EQ3L_125Hz: 1[0.1dB], EQ3R_125Hz: 1[0.1dB], EQ3L_250Hz: 1[0.1dB], EQ3R_250Hz: 1[0.1dB], EQ3L_500Hz: 1[0.1dB], EQ3R_500Hz: 1[0.1dB], EQ3L_1KHz: 1[0.1dB], EQ3R_1KHz: 1[0.1dB], EQ3L_2KHz: 1[0.1dB], EQ3R_2KHz: 1[0.1dB], EQ3L_4KHz: 1[0.1dB], EQ3R_4KHz: 1[0.1dB], EQ3L_8KHz: 1[0.1dB], EQ3R_8KHz: 1[0.1dB], EQ3L_16KHz: 1[0.1dB], EQ3R_16KHz: 1[0.1dB], EQ4L_32Hz: 0[0.1dB], EQ4R_32Hz: 0[0.1dB], EQ4L_64Hz: 0[0.1dB], EQ4R_64Hz: 0[0.1dB], EQ4L_125Hz: 0[0.1dB], EQ4R_125Hz: 0[0.1dB], EQ4L_250Hz: 0[0.1dB], EQ4R_250Hz: 0[0.1dB], EQ4L_500Hz: 0[0.1dB], EQ4R_500Hz: 0[0.1dB], EQ4L_1KHz: 0[0.1dB], EQ4R_1KHz: 0[0.1dB], EQ4L_2KHz: 0[0.1dB], EQ4R_2KHz: 0[0.1dB], EQ4L_4KHz: 0[0.1dB], EQ4R_4KHz: 0[0.1dB], EQ4L_8KHz: 0[0.1dB], EQ4R_8KHz: 0[0.1dB], EQ4L_16KHz: 0[0.1dB], EQ4R_16KHz: 0[0.1dB], EQ5L_32Hz: 0[0.1dB], EQ5R_32Hz: 0[0.1dB], EQ5L_64Hz: 0[0.1dB], EQ5R_64Hz: 0[0.1dB], EQ5L_125Hz: 0[0.1dB], EQ5R_125Hz: 0[0.1dB], EQ5L_250Hz: 0[0.1dB], EQ5R_250Hz: 0[0.1dB], EQ5L_500Hz: 0[0.1dB], EQ5R_500Hz: 0[0.1dB], EQ5L_1KHz: 0[0.1dB], EQ5R_1KHz: 0[0.1dB], EQ5L_2KHz: 0[0.1dB], EQ5R_2KHz: 0[0.1dB], EQ5L_4KHz: 0[0.1dB], EQ5R_4KHz: 0[0.1dB], EQ5L_8KHz: 0[0.1dB], EQ5R_8KHz: 0[0.1dB], EQ5L_16KHz: 0[0.1dB], EQ5R_16KHz: 0[0.1dB], EQ6L_32Hz: 0[0.1dB], EQ6R_32Hz: 0[0.1dB], EQ6L_64Hz: 0[0.1dB], EQ6R_64Hz: 0[0.1dB], EQ6L_125Hz: 0[0.1dB], EQ6R_125Hz: 0[0.1dB], EQ6L_250Hz: 0[0.1dB], EQ6R_250Hz: 0[0.1dB], EQ6L_500Hz: 0[0.1dB], EQ6R_500Hz: 0[0.1dB], EQ6L_1KHz: 0[0.1dB], EQ6R_1KHz: 0[0.1dB], EQ6L_2KHz: 0[0.1dB], EQ6R_2KHz: 0[0.1dB], EQ6L_4KHz: 0[0.1dB], EQ6R_4KHz: 0[0.1dB], EQ6L_8KHz: 0[0.1dB], EQ6R_8KHz: 0[0.1dB], EQ6L_16KHz: 0[0.1dB], EQ6R_16KHz: 0[0.1dB], EQ7L_32Hz: 0[0.1dB], EQ7R_32Hz: 0[0.1dB], EQ7L_64Hz: 0[0.1dB], EQ7R_64Hz: 0[0.1dB], EQ7L_125Hz: 0[0.1dB], EQ7R_125Hz: 0[0.1dB], EQ7L_250Hz: 0[0.1dB], EQ7R_250Hz: 0[0.1dB], EQ7L_500Hz: 0[0.1dB], EQ7R_500Hz: 0[0.1dB], EQ7L_1KHz: 0[0.1dB], EQ7R_1KHz: 0[0.1dB], EQ7L_2KHz: 0[0.1dB], EQ7R_2KHz: 0[0.1dB], EQ7L_4KHz: 0[0.1dB], EQ7R_4KHz: 0[0.1dB], EQ7L_8KHz: 0[0.1dB], EQ7R_8KHz: 0[0.1dB], EQ7L_16KHz: 0[0.1dB], EQ7R_16KHz: 0[0.1dB], EQ8L_32Hz: 0[0.1dB], EQ8R_32Hz: 0[0.1dB], EQ8L_64Hz: 0[0.1dB], EQ8R_64Hz: 0[0.1dB], EQ8L_125Hz: 0[0.1dB], EQ8R_125Hz: 0[0.1dB], EQ8L_250Hz: 0[0.1dB], EQ8R_250Hz: 0[0.1dB], EQ8L_500Hz: 0[0.1dB], EQ8R_500Hz: 0[0.1dB], EQ8L_1KHz: 0[0.1dB], EQ8R_1KHz: 0[0.1dB], EQ8L_2KHz: 0[0.1dB], EQ8R_2KHz: 0[0.1dB], EQ8L_4KHz: 0[0.1dB], EQ8R_4KHz: 0[0.1dB], EQ8L_8KHz: 0[0.1dB], EQ8R_8KHz: 0[0.1dB], EQ8L_16KHz: 0[0.1dB], EQ8R_16KHz: 0[0.1dB], PWR1L: ON, PWR1R: ON, PWR2L: ON, PWR2R: ON, PWR3L: ON, PWR3R: ON, PWR4L: ON, PWR4R: ON, PWR5L: ON, PWR5R: ON, PWR6L: ON, PWR6R: ON, PWR7L: ON, PWR7R: ON, PWR8L: ON, PWR8R: ON}
*/
