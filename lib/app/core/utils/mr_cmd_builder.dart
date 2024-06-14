import '../enums/device_type.dart';
import '../enums/multiroom_commands.dart';
import '../enums/zone_mode.dart';
import '../extensions/map_extensions.dart';
import '../extensions/string_extensions.dart';
import '../models/channel_model.dart';
import '../models/frequency.dart';
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

  static String get configs => MultiroomCommands.mrCfgShow.value;

  static String get params => MultiroomCommands.mrParShow.value;

  static String get expansionMode => MultiroomCommands.mrExpModeGet.value;

  static String get setDefaultConfigs => MultiroomCommands.mrCfgDefaultSet.value;

  static String get setDefaultParams => MultiroomCommands.mrParDefaultSet.value;

  static String setExpansionMode({
    required DeviceType type,
  }) =>
      "${MultiroomCommands.mrExpModeSet.value},${type.name}";

  static String getZoneMode({
    required ZoneModel zone,
  }) =>
      "${MultiroomCommands.mrZoneModeGet.value},${zone.id}";

  static String setZoneMode({
    required ZoneWrapperModel zone,
    required ZoneMode mode,
  }) =>
      "${MultiroomCommands.mrZoneModeSet.value},${zone.id},${mode.name}";

  static String getChannel({
    required ZoneModel zone,
  }) =>
      "${MultiroomCommands.mrZoneChannelGet.value},${zone.id}";

  static String setChannel({
    required ZoneModel zone,
    required ChannelModel channel,
  }) =>
      "${MultiroomCommands.mrZoneChannelSet.value},${zone.id},${channel.id}";

  static String getMute({
    required ZoneModel zone,
  }) =>
      "${MultiroomCommands.mrMuteGet.value},${zone.id}";

  static String setMute({
    required ZoneModel zone,
    required bool active,
  }) =>
      "${MultiroomCommands.mrMuteSet.value},${zone.id},${active ? "on" : "off"}";

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
      "${MultiroomCommands.mrEqGet.value},${zone.id},${frequency.name}";

  static String setEqualizer({
    required ZoneModel zone,
    required Frequency frequency,
    required int gain,
  }) =>
      "${MultiroomCommands.mrEqSet.value},${zone.id},${frequency.name},$gain";
}
