import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../../enums/device_type.dart';
import '../../enums/mono_side.dart';
import '../../enums/zone_mode.dart';
import '../../models/channel_model.dart';
import '../../models/device_model.dart';
import '../../models/equalizer_model.dart';
import '../../models/frequency.dart';
import '../../models/mono_zones.dart';
import '../../models/project_model.dart';
import '../../models/zone_group_model.dart';
import '../../models/zone_model.dart';
import '../../models/zone_wrapper_model.dart';

class HiveUtils {
  static const boxName = "multiroom_db";

  static Future<Box> init() async {
    // Register all Hive Adapters on storage/hive_helper/hive_adapters.dart file
    _registerAdapters();

    return loadBox();
  }

  static Future<Box> loadBox() async {
    await closeBox();

    final dir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(dir.path);

    return Hive.openBox(boxName);
  }

  static Future<void> closeBox() async {
    if (Hive.isBoxOpen(boxName)) {
      await Hive.close();
    }
  }
}

void _registerAdapters() {
  Hive.registerAdapter(ChannelModelAdapter());
  Hive.registerAdapter(DeviceModelAdapter());
  Hive.registerAdapter(EqualizerModelAdapter());
  Hive.registerAdapter(FrequencyAdapter());
  Hive.registerAdapter(ProjectModelAdapter());
  Hive.registerAdapter(ZoneGroupModelAdapter());
  Hive.registerAdapter(ZoneModelAdapter());
  Hive.registerAdapter(ZoneWrapperModelAdapter());
  Hive.registerAdapter(DeviceTypeAdapter());
  Hive.registerAdapter(MonoSideAdapter());
  Hive.registerAdapter(ZoneModeAdapter());
  Hive.registerAdapter(MonoZonesAdapter());
}
