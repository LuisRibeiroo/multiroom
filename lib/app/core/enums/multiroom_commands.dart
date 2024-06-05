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
}
