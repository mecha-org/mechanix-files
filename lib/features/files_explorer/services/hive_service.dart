import 'dart:io';
import 'package:files/core/constants/hive_tables.dart';
import 'package:files/features/files_explorer/data/models/app_settings.dart';
import 'package:files/features/recents/data/models/recent_files.dart';
import 'package:hive/hive.dart';

class HiveService {
  static Future<void> init() async {
    final home = Platform.environment['HOME'];
    final xdgConfig = Platform.environment['XDG_CONFIG_HOME'];
    final baseDir = xdgConfig ?? '$home/.config';
    final appDir = Directory('$baseDir/mechanix_files');

    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }

    Hive.init(appDir.path);
    Hive.registerAdapter(AppSettingsAdapter());
    Hive.registerAdapter(RecentFileAdapter());

    await Hive.openBox<AppSettings>(HiveTables.appSettingsTable);
  }
}
