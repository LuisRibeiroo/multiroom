import 'package:signals/signals_flutter.dart';

import '../../../../core/enums/page_state.dart';
import '../../../../core/interactor/controllers/base_controller.dart';
import '../../../../core/models/device_model.dart';

class DeviceConfigurationPageController extends BaseController {
  DeviceConfigurationPageController() : super(InitialState());

  final deviceName = "".toSignal(debugLabel: "deviceName");
  final device = DeviceModel.empty().toSignal(debugLabel: "device");
  final isEditing = false.toSignal(debugLabel: "isEditing");

  void init({required DeviceModel device}) {
    this.device.value = device;

    deviceName.value = device.name;
  }

  void toggleEditing() {
    isEditing.value = isEditing.value == false;

    if (isEditing.value == false) {
      device.value = device.value.copyWith(name: deviceName.value);
    }
  }

  @override
  void dispose() {
    super.dispose();

    deviceName.value = deviceName.initialValue;
    device.value = device.initialValue;
    isEditing.value = isEditing.initialValue;
  }
}
