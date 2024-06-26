import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

class HiveUtils {
  static Future<void> init() async {
    // Register all Hive Adapters on storage/hive_helper/hive_adapters.dart file
    _registerAdapters();

    final dir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(dir.path);

    // Hive.box<DailyEntry>(name: 'daily_entries_db');
    // Hive.box<Settings>(name: 'settings_db');
  }
}

void _registerAdapters() {
  // Hive.registerAdapter<DailyEntry>(
  //   '$DailyEntry',
  //   (value) => DailyEntry.fromMap(value as Map<String, dynamic>),
  // );
  
}
