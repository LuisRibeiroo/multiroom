import 'package:signals/signals_flutter.dart';

import '../../../../injector.dart';
import '../../../core/enums/page_state.dart';
import '../../../core/extensions/list_extensions.dart';
import '../../../core/extensions/string_extensions.dart';
import '../../../core/interactor/controllers/base_controller.dart';
import '../../../core/interactor/repositories/settings_contract.dart';
import '../../../core/models/channel_model.dart';
import '../../../core/models/device_model.dart';
import '../../../core/models/zone_group_model.dart';
import '../../../core/models/zone_model.dart';
import '../../../core/models/zone_wrapper_model.dart';

class EditChannelsBottomSheetController extends BaseController {
  EditChannelsBottomSheetController() : super(InitialState());

  final _settings = injector.get<SettingsContract>();

  final device = DeviceModel.empty().asSignal(debugLabel: "device");
  final zone = ZoneModel.empty().asSignal(debugLabel: "zone");
  final isEditMode = false.asSignal(debugLabel: "isEditMode");
  final channels = mapSignal(<String, String>{}, debugLabel: "channels");

  void init({
    required DeviceModel device,
    required ZoneModel zone,
  }) {
    this.device.value = device;
    this.zone.value = zone;
  }

  void toggleEditMode() {
    isEditMode.value = !isEditMode.value;

    if (isEditMode.value) {
      channels.value = device.value.channels.fold(<String, String>{}, (pv, v) => pv..[v.id] = v.name);
    } else {
      DeviceModel newDevice = DeviceModel.empty();
      ZoneModel newZone = zone.value;
      List<ChannelModel> tempChannels = device.value.channels;
      List<ZoneGroupModel> tempGroups = device.value.groups;
      List<ZoneWrapperModel> tempWrappers = device.value.zoneWrappers;

      for (final channel in tempChannels) {
        final newChannel = ChannelModel.builder(
          index: int.parse(channel.id.numbersOnly),
          name: channels[channel.id] ?? channel.name,
        );
        tempChannels = tempChannels.withReplacement((c) => c.id == channel.id, newChannel);

        if (newZone.channel.id == newChannel.id) {
          newZone = newZone.copyWith(channel: newChannel);
        }

        if (device.value.isZoneInGroup(newZone)) {
          final currentGroup = device.value.groups.firstWhere((g) => g.zones.containsZone(newZone));
          final newZones = currentGroup.zones.withReplacement((z) => z.id == newZone.id, newZone);
          final newGroup = currentGroup.copyWith(zones: newZones);

          tempGroups = tempGroups.withReplacement((g) => g.id == newGroup.id, newGroup);
        }

        final wrapper =
            device.value.zoneWrappers.firstWhere((zw) => zw.id == newZone.wrapperId).copyWith(zone: newZone);
        tempWrappers = tempWrappers.withReplacement((z) => z.id == wrapper.id, wrapper);
      }

      newDevice = device.value.copyWith(
        zoneWrappers: tempWrappers,
        groups: tempGroups,
        channels: tempChannels,
      );

      zone.value = newZone;
      device.value = newDevice;

      _settings.saveDevice(device: device.value);
    }
  }

  void onChangeChannelName(String chanelId, String value) {
    channels[chanelId] = value;
  }

  void dispose() {
    super.baseDispose(key: "$runtimeType");

    device.value = device.initialValue;
    zone.value = zone.initialValue;
    isEditMode.value = isEditMode.initialValue;
  }
}
