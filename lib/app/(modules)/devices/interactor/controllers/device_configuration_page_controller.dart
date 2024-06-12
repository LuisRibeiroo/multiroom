import 'package:signals/signals_flutter.dart';

import '../../../../core/enums/mono_side.dart';
import '../../../../core/enums/page_state.dart';
import '../../../../core/enums/zone_mode.dart';
import '../../../../core/interactor/controllers/base_controller.dart';
import '../../../../core/models/device_model.dart';
import '../../../../core/models/zone_model.dart';
import '../../../../core/models/zone_wrapper_model.dart';

class DeviceConfigurationPageController extends BaseController {
  DeviceConfigurationPageController() : super(InitialState());

  final deviceName = "".toSignal(debugLabel: "deviceName");
  final device = DeviceModel.empty().toSignal(debugLabel: "device");
  final editingWrapper = ZoneWrapperModel.empty().toSignal(debugLabel: "editingWrapper");
  final editingZone = ZoneModel.empty().toSignal(debugLabel: "editingZone");
  final isEditingDevice = false.toSignal(debugLabel: "isEditingDevice");
  final isEditingZone = false.toSignal(debugLabel: "isEditingZone");

  void init({required DeviceModel device}) {
    this.device.value = device;

    deviceName.value = device.name;
  }

  void toggleEditingDevice() {
    isEditingDevice.value = isEditingDevice.value == false;

    if (isEditingDevice.value == false) {
      device.value = device.value.copyWith(name: deviceName.value);
    }
  }

  void onTapEditZone(ZoneWrapperModel zone) {
    editingWrapper.value = zone;
  }

  void onChangeZoneMode(ZoneWrapperModel zone, bool isStereo) {
    isEditingZone.value = false;
    editingZone.value = editingZone.initialValue;

    editingWrapper.value = zone.copyWith(mode: isStereo ? ZoneMode.stereo : ZoneMode.mono);

    device.value = device.value
        .copyWith(zones: device.value.zones.map((z) => z.id == zone.id ? editingWrapper.value : z).toList());
  }

  void onChangeZoneName(ZoneModel zone, String value) {
    if (editingWrapper.value.isStereo) {
      editingWrapper.value = editingWrapper.value.copyWith(stereoZone: zone.copyWith(name: value));
    } else {
      if (zone.side == MonoSide.left) {
        editingWrapper.value = editingWrapper.value
            .copyWith(monoZones: (left: zone.copyWith(name: value), right: editingWrapper.value.monoZones.right));
      } else {
        editingWrapper.value = editingWrapper.value
            .copyWith(monoZones: (right: zone.copyWith(name: value), left: editingWrapper.value.monoZones.right));
      }
    }
  }

  void toggleEditingZone(ZoneWrapperModel wrapper, ZoneModel zone) {
    if (wrapper.id == editingWrapper.value.id && zone.id == editingZone.value.id) {
      isEditingZone.value = !isEditingZone.value;
    } else {
      isEditingZone.value = true;
      editingWrapper.value = wrapper;
      editingZone.value = zone;
    }

    if (isEditingZone.value == false) {
      device.value = device.value.copyWith(
        zones: device.value.zones
            .map(
              (z) => z.id == editingWrapper.value.id ? editingWrapper.value : z,
            )
            .toList(),
      );

      editingZone.value = editingZone.initialValue;
      editingWrapper.value = editingWrapper.initialValue;
    }
  }

  @override
  void dispose() {
    super.dispose();

    deviceName.value = deviceName.initialValue;
    device.value = device.initialValue;
    editingWrapper.value = editingWrapper.initialValue;
    editingZone.value = editingZone.initialValue;
    isEditingDevice.value = isEditingDevice.initialValue;
    isEditingZone.value = isEditingZone.initialValue;
  }
}
