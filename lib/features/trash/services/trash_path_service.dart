import 'dart:io';

class TrashPathsService {
  static bool _initialized = false;

  static late Directory trashBaseDir;
  static late Directory trashFilesDir;
  static late Directory trashInfoDir;

  static Future<void> init() async {
    if (_initialized) return;

    final home = Platform.environment['HOME'];
    final xdgData =
        Platform.environment['XDG_DATA_HOME'] ?? '$home/.local/share';

    trashBaseDir = Directory('$xdgData/Trash');
    trashFilesDir = Directory('${trashBaseDir.path}/files');
    trashInfoDir = Directory('${trashBaseDir.path}/info');

    await trashBaseDir.create(recursive: true);
    await trashFilesDir.create(recursive: true);
    await trashInfoDir.create(recursive: true);

    _initialized = true;
  }
}
