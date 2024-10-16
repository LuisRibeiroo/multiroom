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

typedef AllZonesParsedResponse = ({
  String zoneId,
  String response,
});

typedef ZoneDataResponse = ({
  bool power,
  String channel,
  int volume,
  int balance,
});

final class ZoneData {
  const ZoneData._({
    required this.zoneId,
    required this.values,
  });

  factory ZoneData._fromAllZonesInfo({
    required AllZonesParsedResponse powerResponse,
    required AllZonesParsedResponse channelResponse,
    required AllZonesParsedResponse volumeResponse,
    required AllZonesParsedResponse balanceResponse,
  }) {
    return ZoneData._(
      zoneId: powerResponse.zoneId,
      values: (
        power: powerResponse.response.toLowerCase() == "on",
        channel: channelResponse.response,
        volume: int.tryParse(volumeResponse.response) ?? 0,
        balance: int.tryParse(balanceResponse.response) ?? 0,
      ),
    );
  }

  final String zoneId;
  final ZoneDataResponse values;

  static List<ZoneData> buildAllZones({
    required List<AllZonesParsedResponse> powerResponse,
    required List<AllZonesParsedResponse> channelResponse,
    required List<AllZonesParsedResponse> volumeResponse,
    required List<AllZonesParsedResponse> balanceResponse,
  }) {
    if (powerResponse.length != channelResponse.length || powerResponse.length != volumeResponse.length) {
      throw Exception("All responses need to be same lenght");
    }

    final ret = <ZoneData>[];

    for (var i = 0; i < powerResponse.length; i++) {
      ret.add(
        ZoneData._fromAllZonesInfo(
          powerResponse: powerResponse[i],
          channelResponse: channelResponse[i],
          volumeResponse: volumeResponse[i],
          balanceResponse: balanceResponse[i],
        ),
      );
    }

    return ret;
  }
}

abstract final class MrCmdBuilder {
  static const allZones = "ZALL";

  static String parseResponseSingle(String response) =>
      MrCmdBuilder.parseCompleteResponse(response, single: true).response;

  static String parseResponseMulti(String response) =>
      MrCmdBuilder.parseCompleteResponse(response, single: false).response;

  static List<AllZonesParsedResponse> parseResponseAllZones(String response) {
    final ret = <AllZonesParsedResponse>[];

    for (final line in response.split("\n")) {
      if (line.isNullOrEmpty) {
        continue;
      }

      final parsed = MrCmdBuilder.parseCompleteResponse(line, single: true);
      ret.add((zoneId: parsed.params, response: parsed.response));
    }

    return ret;
  }

  static MrResponse parseCompleteResponse(String response, {required bool single}) {
    final ret = response.split(",");

    return (
      cmd: ret.first.removeSpecialChars,
      macAddress: ret[1].removeSpecialChars,
      params: ret[2].removeSpecialChars,
      // response: ret.last.removeSpecialChars,
      response:
          single ? ret.last.removeSpecialChars : ret.getRange(3, ret.length).map((e) => e.removeSpecialChars).join(","),
      frequency: null,
    );
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

  static String getChannelAll({
    required String macAddress,
  }) =>
      "${MultiroomCommands.mrZoneChannelGet.value},$macAddress,$allZones";

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

  static String getPowerAll({
    required String macAddress,
  }) =>
      "${MultiroomCommands.mrPwrGet.value},$macAddress,$allZones";

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

  static String getVolumeAll({
    required String macAddress,
  }) =>
      "${MultiroomCommands.mrVolGet.value},$macAddress,$allZones";

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

  static String getBalanceAll({
    required String macAddress,
  }) =>
      "${MultiroomCommands.mrBalGet.value},$macAddress,$allZones";

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

  static String getEqualizerAll({
    required String macAddress,
    required ZoneModel zone,
  }) =>
      "${MultiroomCommands.mrEqGetAll.value},$macAddress,${zone.id}";

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
