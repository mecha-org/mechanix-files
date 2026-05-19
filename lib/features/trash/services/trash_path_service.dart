import 'dart:io';

class TrashPathsService {
  static late Directory trashBaseDir;
  static late Directory trashFilesDir;
  static late Directory trashInfoDir;

  static Future<void> init() async {
    final home = Platform.environment['HOME'];
    final xdgData =
        Platform.environment['XDG_DATA_HOME'] ?? '$home/.local/share';

    trashBaseDir = Directory('$xdgData/Trash');

    trashFilesDir = Directory('${trashBaseDir.path}/files');

    trashInfoDir = Directory('${trashBaseDir.path}/info');

    if (!await trashBaseDir.exists()) {
      await trashBaseDir.create(recursive: true);
    }

    if (!await trashFilesDir.exists()) {
      await trashFilesDir.create(recursive: true);
    }

    if (!await trashInfoDir.exists()) {
      await trashInfoDir.create(recursive: true);
    }
  }
}
