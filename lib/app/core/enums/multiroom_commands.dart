enum MultiroomCommands {
  /// --> User commands
  mrParShow(value: "mr_par_show"),
  mrParDefaultSet(value: "mr_par_default_set"),
  mrZoneChannelGet(value: "mr_zone_channel_get"),
  mrZoneChannelSet(value: "mr_zone_channel_set"),
  mrVolGet(value: "mr_vol_get"),
  mrVolSet(value: "mr_vol_set"),
  mrBalGet(value: "mr_bal_get"),
  mrBalSet(value: "mr_bal_set"),
  mrEqGet(value: "mr_eq_get"),
  mrEqSet(value: "mr_eq_set"),
  mrPwrSet(value: "mr_power_set"),
  mrPwrGet(value: "mr_power_get"),

  /// --> Technician commands
  mrCfgDefaultSet(value: "mr_cfg_default_set"),
  mrExpModeGet(value: "mr_exp_mode_get"),
  mrExpModeSet(value: "mr_exp_mode_set"),
  mrZoneModeGet(value: "mr_zone_mode_get"),
  mrGroupGet(value: "mr_group_get"),
  mrGroupSet(value: "mr_group_set"),
  mrZoneModeSet(value: "mr_zone_mode_set"),
  mrVolMaxSet(value: "mr_lim_per_set"),
  mrVolMaxGet(value: "mr_lim_per_get"),
  mrFirmwareGet(value: "get_firmware_version");

  const MultiroomCommands({required this.value});

  final String value;

  static MultiroomCommands? fromString(String value) {
    for (final v in MultiroomCommands.values) {
      if (v.value == value) {
        return v;
      }
    }

    return null;
  }
}
