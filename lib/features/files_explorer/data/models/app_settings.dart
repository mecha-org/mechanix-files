import 'package:hive/hive.dart';

part 'app_settings.g.dart';

const String appSettingsTable = "appSettingsTable";

@HiveType(typeId: 0)
class AppSettings extends HiveObject {
  @HiveField(0)
  bool showHiddenFiles;

  AppSettings({required this.showHiddenFiles});

  @override
  String toString() {
    return 'AppSettings(showHiddenFiles: $showHiddenFiles)';
  }

  AppSettings copyWith({bool? showHiddenFiles}) {
    return AppSettings(
      showHiddenFiles: showHiddenFiles ?? this.showHiddenFiles,
    );
  }
}
