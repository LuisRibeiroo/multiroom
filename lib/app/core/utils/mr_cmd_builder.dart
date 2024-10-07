import '../enums/device_type.dart';
import '../enums/multiroom_commands.dart';
import '../enums/zone_mode.dart';
import '../extensions/map_extensions.dart';
import '../extensions/string_extensions.dart';
import '../models/channel_model.dart';
import '../models/frequency.dart';
import '../models/zone_group_model.dart';
import '../models/zone_model.dart';
import '../models/zone_wrapper_model.dart';

abstract final class MrCmdBuilder {
  static String parseResponse(String response) => response.split("=").lastOrNull?.removeSpecialChars ?? response;

  static Map<String, String> parseConfigs(String response) {
    final configs = <String, String>{};

    for (final cfg in response.split("\n").sublist(1)) {
      final splited = cfg.split("=");
      final (param, value) = (splited.first, splited.last.removeSpecialChars);

      configs[param] = value;
    }

    return configs..removeNulls();
  }

  static int fromDbToPercent(String value) =>
      (4.25 * ((double.tryParse(value.numbersOnly) ?? -400.00) / 100) + 117).toInt();

  static int fromPercentToDb(int value) => (((value - 117) / 4.25) * 100).truncate();

  static String get params => MultiroomCommands.mrParShow.value;

  static String get expansionMode => MultiroomCommands.mrExpModeGet.value;

  static String get firmwareVersion => MultiroomCommands.mrFirmwareGet.value;

  static String get setDefaultConfigs => MultiroomCommands.mrCfgDefaultSet.value;

  static String get setDefaultParams => MultiroomCommands.mrParDefaultSet.value;

  static String setExpansionMode({
    required String macAddress,
    required DeviceType type,
  }) =>
      "${MultiroomCommands.mrExpModeSet.value},$macAddress,${type.name}";

  static String getZoneMode({
    required ZoneModel zone,
  }) =>
      "${MultiroomCommands.mrZoneModeGet.value},${zone.id}";

  static String setZoneMode({
    required ZoneWrapperModel zone,
    required ZoneMode mode,
  }) =>
      "${MultiroomCommands.mrZoneModeSet.value},${zone.id.replaceAll("W", "")},${mode.name}";

  static String getChannel({
    required ZoneModel zone,
  }) =>
      "${MultiroomCommands.mrZoneChannelGet.value},${zone.id}";

  static String setChannel({
    required ZoneModel zone,
    required ChannelModel channel,
  }) =>
      "${MultiroomCommands.mrZoneChannelSet.value},${zone.id},${channel.id}";

  static String getPower({
    required ZoneModel zone,
  }) =>
      "${MultiroomCommands.mrPwrGet.value},${zone.id}";

  static String setPower({
    required ZoneModel zone,
    required bool active,
  }) =>
      "${MultiroomCommands.mrPwrSet.value},${zone.id},${active ? "on" : "off"}";

  static String getVolume({
    required ZoneModel zone,
  }) =>
      "${MultiroomCommands.mrVolGet.value},${zone.id}";

  static String setVolume({
    required ZoneModel zone,
    required int volume,
  }) =>
      "${MultiroomCommands.mrVolSet.value},${zone.id},$volume";

  static String getBalance({
    required ZoneModel zone,
  }) =>
      "${MultiroomCommands.mrBalGet.value},${zone.id}";

  static String setBalance({
    required ZoneModel zone,
    required int balance,
  }) =>
      "${MultiroomCommands.mrBalSet.value},${zone.id},$balance";

  static String getEqualizer({
    required ZoneModel zone,
    required Frequency frequency,
  }) =>
      "${MultiroomCommands.mrEqGet.value},${zone.id},${frequency.id}";

  static String setEqualizer({
    required ZoneModel zone,
    required Frequency frequency,
    required int gain,
  }) =>
      "${MultiroomCommands.mrEqSet.value},${zone.id},${frequency.id},${gain * 10}";

  static String getGroup({
    required int groupId,
  }) =>
      "${MultiroomCommands.mrGroupGet.value},$groupId";

  static String setGroup({
    required ZoneGroupModel group,
    required List<ZoneModel> zones,
  }) =>
      "${MultiroomCommands.mrGroupSet.value},${group.id.numbersOnly},${zones.map((z) => z.id).join(",")}";

  static String getMaxVolume({
    required ZoneModel zone,
  }) =>
      "${MultiroomCommands.mrVolMaxGet.value},${zone.id}";

  static String setMaxVolume({
    required ZoneModel zone,
    required int volumePercent,
  }) =>
      "${MultiroomCommands.mrVolMaxSet.value},${zone.id},$volumePercent";
}
