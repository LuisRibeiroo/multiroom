import 'package:signals/signals_flutter.dart';

import '../../../../injector.dart';
import '../../../core/enums/page_state.dart';
import '../../../core/interactor/controllers/base_controller.dart';
import '../../../core/interactor/repositories/settings_contract.dart';
import '../../../core/models/device_model.dart';

class ConfigsPageController extends BaseController {
  ConfigsPageController() : super(InitialState()) {
    localDevices.value = settings.devices;
  }

  final settings = injector.get<SettingsContract>();

  final device = DeviceModel.empty().toSignal(debugLabel: "currentDevice");
  final localDevices = listSignal<DeviceModel>([], debugLabel: "localDevices");

  void onChangeActive(DeviceModel device, bool value) {
    localDevices[localDevices.indexOf(device)] = device.copyWith(active: value);
  }

  @override
  void dispose() {
    super.dispose();

    localDevices.value = <DeviceModel>[];
    device.value = device.initialValue;
  }
}

/*
Configs Response
{EXP_MODE: MASTER, MODE1: STEREO, MODE2: MONO, MODE3: MONO, MODE4: STEREO, MODE5: STEREO, MODE6: STEREO, MODE7: STEREO, MODE8: MONO, VOL_MAX1L: 100[%], VOL_MAX1R: 100[%], VOL_MAX2L: 100[%], VOL_MAX2R: 100[%], VOL_MAX3L: 100[%], VOL_MAX3R: 100[%], VOL_MAX4L: 100[%], VOL_MAX4R: 100[%], VOL_MAX5L: 100[%], VOL_MAX5R: 100[%], VOL_MAX6L: 100[%], VOL_MAX6R: 100[%], VOL_MAX7L: 100[%], VOL_MAX7R: 100[%], VOL_MAX8L: 100[%], VOL_MAX8R: 100[%], GRP[1][1]: (null), GRP[1][2]: (null), GRP[1][3]: (null), GRP[1][4]: (null), GRP[1][5]: (null), GRP[1][6]: (null), GRP[1][7]: (null), GRP[1][8]: (null), GRP[1][9]: (null), GRP[1][10]: (null), GRP[1][11]: (null), GRP[1][12]: (null), GRP[1][13]: (null), GRP[1][14]: (null), GRP[1][15]: (null), GRP[1][16]: (null), GRP[2][1]: (null), GRP[2][2]: (null), GRP[2][3]: (null), GRP[2][4]: (null), GRP[2][5]: (null), GRP[2][6]: (null), GRP[2][7]: (null), GRP[2][8]: (null), GRP[2][9]: (null), GRP[2][10]: (null), GRP[2][11]: (null), GRP[2][12]: (null), GRP[2][13]: (null), GRP[2][14]: (null), GRP[2][15]: (null), GRP[2][16]: (null), GRP[3][1]: (null), GRP[3][2]: (null), GRP[3][3]: (null), GRP[3][4]: (null), GRP[3][5]: (null), GRP[3][6]: (null), GRP[3][7]: (null), GRP[3][8]: (null), GRP[3][9]: (null), GRP[3][10]: (null), GRP[3][11]: (null), GRP[3][12]: (null), GRP[3][13]: (null), GRP[3][14]: (null), GRP[3][15]: (null), GRP[3][16]: (null)}
*/
