import 'package:collection/collection.dart';
import 'package:signals/signals_flutter.dart';

import '../../../../injector.dart';
import '../../../core/enums/mono_side.dart';
import '../../../core/enums/page_state.dart';
import '../../../core/extensions/list_extensions.dart';
import '../../../core/interactor/controllers/base_controller.dart';
import '../../../core/interactor/repositories/settings_contract.dart';
import '../../../core/models/device_model.dart';
import '../../../core/models/project_model.dart';
import '../../../core/models/zone_model.dart';
import '../../../core/models/zone_wrapper_model.dart';

class EditZonesPageController extends BaseController {
  EditZonesPageController() : super(InitialState());

  final _settings = injector.get<SettingsContract>();

  final project = ProjectModel.empty().toSignal(debugLabel: "project");
  final isEditing = false.toSignal(debugLabel: "isEditing");
  final editingDeviceSerial = "".toSignal(debugLabel: "editingDeviceSerial");
  final editingZoneId = "".toSignal(debugLabel: "editingZoneId");
  final editingZoneName = "".toSignal(debugLabel: "editingZoneName");

  void init({required ProjectModel project}) {
    this.project.value = project;
  }

  void onChangeZoneName(String zoneId, String value) {
    editingZoneId.value = zoneId;
    editingZoneName.value = value;
  }

  void toggleEditing(DeviceModel device, ZoneModel zone) {
    if (editingZoneId.value == zone.id && device.serialNumber == editingDeviceSerial.value) {
      isEditing.value = !isEditing.value;
    } else {
      isEditing.value = true;
      editingZoneId.value = zone.id;
      editingDeviceSerial.value = device.serialNumber;
      editingZoneName.value = device.groupedZones.firstWhere((z) => z.id == zone.id).name;

      return;
    }

    if (isEditing.value == false) {
      DeviceModel newDevice = DeviceModel.empty();
      // final List<ChannelModel> newChannels = List.from(zone.peek().channels);
      if (zone.isGroup) {
        final currentGroup = device.groups.firstWhere((g) => g.zones.firstWhereOrNull((z) => z.id == zone.id) != null);
        final newGroup = currentGroup.copyWith(name: editingZoneName.value);

        final newGroups = device.groups..replaceWhere((g) => g.id == newGroup.id, newGroup);
        newDevice = device.copyWith(groups: newGroups);
      } else {
        final newZone = device.zones.firstWhere((c) => c.id == zone.id).copyWith(name: editingZoneName.value);

        ZoneWrapperModel wrapper = device.zoneWrappers.firstWhere((zw) => zw.id == zone.wrapperId);
        if (wrapper.isStereo) {
          wrapper = wrapper.copyWith(stereoZone: newZone);
        } else {
          if (zone.side == MonoSide.right) {
            wrapper = wrapper.copyWith(monoZones: wrapper.monoZones.copyWith(right: newZone));
          } else {
            wrapper = wrapper.copyWith(monoZones: wrapper.monoZones.copyWith(left: newZone));
          }
        }

        final newWrappers = device.zoneWrappers..replaceWhere((z) => z.id == wrapper.id, wrapper);
        newDevice = device.copyWith(zoneWrappers: newWrappers);
      }

      final newDevices = project.peek().devices..replaceWhere((d) => d.serialNumber == device.serialNumber, newDevice);
      project.value = project.peek().copyWith(devices: newDevices);

      _settings.saveProject(project.value);

      editingZoneId.value = editingZoneId.initialValue;
      editingZoneName.value = editingZoneName.initialValue;
      editingDeviceSerial.value = editingDeviceSerial.initialValue;
    }
  }

  @override
  void dispose() {
    super.dispose();

    project.value = project.initialValue;
    isEditing.value = isEditing.initialValue;
    editingDeviceSerial.value = editingZoneId.initialValue;
    editingZoneId.value = editingZoneName.initialValue;
    editingZoneName.value = editingDeviceSerial.initialValue;
  }
}
