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
  mrEqSet(value: "mr_eq_set", singleResponse: false),
  mrPwrSet(value: "mr_power_set"),
  mrPwrGet(value: "mr_power_get"),
  mrEqGetAll(value: "mr_eq_all_get"),
  mrEqSetAll(value: "mr_eq_all_set", singleResponse: false),

  /// --> Technician commands
  mrCfgDefaultSet(value: "mr_cfg_default_set"),
  mrExpModeGet(value: "mr_exp_mode_get"),
  mrExpModeSet(value: "mr_exp_mode_set"),
  mrZoneModeGet(value: "mr_zone_mode_get"),
  mrGroupGet(value: "mr_group_get"),
  mrGroupSet(value: "mr_group_set", singleResponse: false),
  mrZoneModeSet(value: "mr_zone_mode_set"),
  mrVolMaxSet(value: "mr_lim_per_set"),
  mrVolMaxGet(value: "mr_lim_per_get"),
  mrFirmwareGet(value: "get_firmware_version");

  const MultiroomCommands({
    required this.value,
    this.singleResponse = false,
  });

  final String value;
  final bool singleResponse;

  static MultiroomCommands? fromString(String value) {
    if (value.contains(",")) {
      value = value.split(",").first;
    }

    for (final v in MultiroomCommands.values) {
      if (v.value == value) {
        return v;
      }
    }

    return null;
  }

  MultiroomCommands asSet() {
    return switch (this) {
      mrZoneChannelGet => mrZoneChannelSet,
      mrVolGet => mrVolSet,
      mrBalGet => mrBalSet,
      mrEqGet => mrEqSet,
      mrPwrGet => mrPwrSet,
      mrEqGetAll => mrEqSetAll,
      mrExpModeGet => mrExpModeSet,
      mrZoneModeGet => mrZoneModeSet,
      mrGroupGet => mrGroupSet,
      mrVolMaxGet => mrVolMaxSet,
      _ => this,
    };
  }
}
