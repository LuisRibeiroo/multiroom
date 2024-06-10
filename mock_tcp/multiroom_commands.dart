enum MultiroomCommands {
  /// --> User commands
  mrParShow(value: "mr_par_show"),
  mrParDefaultSet(value: "mr_par_default_set"),
  mrZoneChannelGet(value: "mr_zone_channel_get"),
  mrZoneChannelSet(value: "mr_zone_channel_set"),
  mrMuteGet(value: "mr_mute_get"),
  mrMuteSet(value: "mr_mute_set"),
  mrVolGet(value: "mr_vol_get"),
  mrVolSet(value: "mr_vol_set"),
  mrBalGet(value: "mr_bal_get"),
  mrBalSet(value: "mr_bal_set"),
  mrEqGet(value: "mr_eq_get"),
  mrEqSet(value: "mr_eq_set"),

  /// --> Technician commands
  mrCfgShow(value: "mr_cfg_show"),
  mrCfgDefaultSet(value: "mr_cfg_default_set"),
  mrExpModeGet(value: "mr_exp_mode_get"),
  mrExpModeSet(value: "mr_exp_mode_set"),
  mrZoneModeGet(value: "mr_zone_mode_get"),
  mrZoneModeSet(value: "mr_zone_mode_set");

  const MultiroomCommands({required this.value});

  final String value;

  static MultiroomCommands fromString(String data) {
    return switch (data) {
      "mr_par_show" => MultiroomCommands.mrParShow,
      "mr_par_default_set" => MultiroomCommands.mrParDefaultSet,
      "mr_zone_channel_get" => MultiroomCommands.mrZoneChannelGet,
      "mr_zone_channel_set" => MultiroomCommands.mrZoneChannelSet,
      "mr_mute_get" => MultiroomCommands.mrMuteGet,
      "mr_mute_set" => MultiroomCommands.mrMuteSet,
      "mr_vol_get" => MultiroomCommands.mrVolGet,
      "mr_vol_set" => MultiroomCommands.mrVolSet,
      "mr_bal_get" => MultiroomCommands.mrBalGet,
      "mr_bal_set" => MultiroomCommands.mrBalSet,
      "mr_eq_get" => MultiroomCommands.mrEqGet,
      "mr_eq_set" => MultiroomCommands.mrEqSet,
      "mr_cfg_show" => MultiroomCommands.mrCfgShow,
      "mr_cfg_default_set" => MultiroomCommands.mrCfgDefaultSet,
      "mr_exp_mode_get" => MultiroomCommands.mrExpModeGet,
      "mr_exp_mode_set" => MultiroomCommands.mrExpModeSet,
      "mr_zone_mode_get" => MultiroomCommands.mrZoneModeGet,
      "mr_zone_mode_set" => MultiroomCommands.mrZoneModeSet,
      _ => throw Exception("Invalid command --> [${data}]"),
    };
  }
}
