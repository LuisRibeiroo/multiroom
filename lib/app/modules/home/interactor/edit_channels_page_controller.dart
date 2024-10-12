import 'package:signals/signals_flutter.dart';

import '../../../../injector.dart';
import '../../../core/enums/page_state.dart';
import '../../../core/extensions/list_extensions.dart';
import '../../../core/extensions/string_extensions.dart';
import '../../../core/interactor/controllers/base_controller.dart';
import '../../../core/interactor/repositories/settings_contract.dart';
import '../../../core/models/channel_model.dart';
import '../../../core/models/device_model.dart';
import '../../../core/models/zone_model.dart';
import '../../../core/models/zone_wrapper_model.dart';

class EditChannelsPageController extends BaseController {
  EditChannelsPageController() : super(InitialState());

  final _settings = injector.get<SettingsContract>();

  final device = DeviceModel.empty().asSignal(debugLabel: "device");
  final zone = ZoneModel.empty().asSignal(debugLabel: "zone");
  final isEditing = false.asSignal(debugLabel: "isEditingChannel");
  final editingChannelId = "".asSignal(debugLabel: "editingChannelId");
  final editingChannelName = "".asSignal(debugLabel: "editingChannelName");

  void init({required DeviceModel device, required ZoneModel zone}) {
    this.device.value = device;
    this.zone.value = zone;
  }

  void onChangeChannelName(String chanelId, String value) {
    editingChannelId.value = chanelId;
    editingChannelName.value = value;
  }

  void toggleEditing(String channelId) {
    if (editingChannelId.value == channelId) {
      isEditing.value = !isEditing.value;
    } else {
      isEditing.value = true;
      editingChannelId.value = channelId;
      editingChannelName.value = zone.value.channels
          .firstWhere(
            (c) => c.id == channelId,
          )
          .name;

      return;
    }

    if (isEditing.value == false) {
      final List<ChannelModel> newChannels = List.from(zone.peek().channels);

      final newZone = zone.value.copyWith(
        channels: newChannels.withReplacement(
          (c) => c.id == channelId,
          ChannelModel.builder(
            index: int.parse(channelId.numbersOnly),
            name: editingChannelName.value,
          ),
        ),
      );

      zone.value = newZone;

      ZoneWrapperModel wrapper = device.value.zoneWrappers.firstWhere((zw) => zw.id == zone.value.wrapperId);
      wrapper = wrapper.copyWith(zone: newZone);

      final newWrappers = device.value.zoneWrappers.withReplacement((z) => z.id == wrapper.id, wrapper);

      device.value = device.peek().copyWith(zoneWrappers: newWrappers);
      _settings.saveDevice(device: device.value);

      editingChannelId.value = editingChannelId.initialValue;
      editingChannelName.value = editingChannelName.initialValue;
    }
  }

  void dispose() {
    super.baseDispose(key: "$runtimeType");

    device.value = device.initialValue;
    zone.value = zone.initialValue;
    isEditing.value = isEditing.initialValue;
    editingChannelId.value = editingChannelId.initialValue;
    editingChannelName.value = editingChannelName.initialValue;
  }
}
