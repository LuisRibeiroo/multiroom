import 'package:flutter/material.dart';

import '../enums/device_type.dart';
import '../enums/multiroom_commands.dart';
import '../enums/zone_mode.dart';
import '../extensions/string_extensions.dart';
import '../models/channel_model.dart';
import '../models/frequency.dart';
import '../models/zone_group_model.dart';
import '../models/zone_model.dart';
import '../models/zone_wrapper_model.dart';

typedef MrResponse = ({
  String cmd,
  String macAddress,
  String params,
  String response,
  String? frequency,
});

abstract final class MrCmdBuilder {
  // TODO: Remove old return
  static String parseResponse(String response) => MrCmdBuilder.parseCompleteResponse(response).response;

  static parseFullResponse(String response) => MrCmdBuilder.parseCompleteFullResponse(response);

  static MrResponse parseCompleteResponse(String response) {
    final ret = response.split(",");

    return (
      cmd: ret.first.removeSpecialChars,
      macAddress: ret[1].removeSpecialChars,
      params: ret[2].removeSpecialChars,
      response: ret.last.removeSpecialChars,
      frequency: null,
    );
  }

  static List<MrResponse> parseCompleteFullResponse(String response) {
    final retList = <MrResponse>[];
    final cmdResponses = response.split('\r\n');
    debugPrint("[DBG] --> CMD RESPONSES: ${cmdResponses.length}");

    for (final response in cmdResponses) {
      if (response.isEmpty) {
        continue;
      }

      final cmdResponse = response.split(",");

      retList.add((
        cmd: cmdResponse.first.removeSpecialChars,
        macAddress: cmdResponse[1].removeSpecialChars,
        params: cmdResponse[2].removeSpecialChars,
        response: cmdResponse.last.removeSpecialChars,
        frequency: cmdResponse[3].removeSpecialChars,
      ));
    }

    return retList;
  }

  static int fromDbToPercent(String value) =>
      (4.25 * ((double.tryParse(value.numbersOnly) ?? -400.00) / 100) + 117).toInt();

  static int fromPercentToDb(int value) => (((value - 117) / 4.25) * 100).truncate();

  static String params({required String macAddress}) => "${MultiroomCommands.mrParShow.value},$macAddress";

  static String expansionMode({required String macAddress}) => "${MultiroomCommands.mrExpModeGet.value},$macAddress";

  static String firmwareVersion({required String macAddress}) => "${MultiroomCommands.mrFirmwareGet.value},$macAddress";

  static String setDefaultConfigs({required String macAddress}) =>
      "${MultiroomCommands.mrCfgDefaultSet.value},$macAddress";

  static String setDefaultParams({required String macAddress}) =>
      "${MultiroomCommands.mrParDefaultSet.value},$macAddress";

  static String setExpansionMode({
    required String macAddress,
    required DeviceType type,
  }) =>
      "${MultiroomCommands.mrExpModeSet.value},$macAddress,${type.name}";

  static String getZoneMode({
    required String macAddress,
    required ZoneModel zone,
  }) =>
      "${MultiroomCommands.mrZoneModeGet.value},$macAddress,${zone.id}";

  static String setZoneMode({
    required String macAddress,
    required ZoneWrapperModel zone,
    required ZoneMode mode,
  }) =>
      "${MultiroomCommands.mrZoneModeSet.value},$macAddress,${zone.id.replaceAll("W", "")},${mode.name}";

  static String getChannel({
    required String macAddress,
    required ZoneModel zone,
  }) =>
      "${MultiroomCommands.mrZoneChannelGet.value},$macAddress,${zone.id}";

  static String setChannel({
    required String macAddress,
    required ZoneModel zone,
    required ChannelModel channel,
  }) =>
      "${MultiroomCommands.mrZoneChannelSet.value},$macAddress,${zone.id},${channel.id}";

  static String getPower({
    required String macAddress,
    required ZoneModel zone,
  }) =>
      "${MultiroomCommands.mrPwrGet.value},$macAddress,${zone.id}";

  static String setPower({
    required String macAddress,
    required ZoneModel zone,
    required bool active,
  }) =>
      "${MultiroomCommands.mrPwrSet.value},$macAddress,${zone.id},${active ? "on" : "off"}";

  static String getVolume({
    required String macAddress,
    required ZoneModel zone,
  }) =>
      "${MultiroomCommands.mrVolGet.value},$macAddress,${zone.id}";

  static String setVolume({
    required String macAddress,
    required ZoneModel zone,
    required int volume,
  }) =>
      "${MultiroomCommands.mrVolSet.value},$macAddress,${zone.id},$volume";

  static String getBalance({
    required String macAddress,
    required ZoneModel zone,
  }) =>
      "${MultiroomCommands.mrBalGet.value},$macAddress,${zone.id}";

  static String setBalance({
    required String macAddress,
    required ZoneModel zone,
    required int balance,
  }) =>
      "${MultiroomCommands.mrBalSet.value},$macAddress,${zone.id},$balance";

  static String getEqualizer({
    required String macAddress,
    required ZoneModel zone,
    required Frequency frequency,
  }) =>
      "${MultiroomCommands.mrEqGet.value},$macAddress,${zone.id},${frequency.id}";

  static String setEqualizer({
    required String macAddress,
    required ZoneModel zone,
    required Frequency frequency,
    required int gain,
  }) =>
      "${MultiroomCommands.mrEqSet.value},$macAddress,${zone.id},${frequency.id},${gain * 10}";

  static String getGroup({
    required String macAddress,
    required int groupId,
  }) =>
      "${MultiroomCommands.mrGroupGet.value},$macAddress,$groupId";

  static String setGroup({
    required String macAddress,
    required ZoneGroupModel group,
    required List<ZoneModel> zones,
  }) =>
      "${MultiroomCommands.mrGroupSet.value},$macAddress,${group.id.numbersOnly},${zones.map((z) => z.id).join(",")}";

  static String getMaxVolume({
    required String macAddress,
    required ZoneModel zone,
  }) =>
      "${MultiroomCommands.mrVolMaxGet.value},$macAddress,${zone.id}";

  static String setMaxVolume({
    required String macAddress,
    required ZoneModel zone,
    required int volumePercent,
  }) =>
      "${MultiroomCommands.mrVolMaxSet.value},$macAddress,${zone.id},$volumePercent";
}
