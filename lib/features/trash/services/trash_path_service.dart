import 'package:file/file.dart';
import 'dart:io' as io show Platform;

class TrashPathsService {
  static bool _initialized = false;

  static late Directory trashBaseDir;
  static late Directory trashFilesDir;
  static late Directory trashInfoDir;

  static Future<void> init(FileSystem fs, {String? homeOverride}) async {
    if (_initialized) return;

    final home = homeOverride ?? io.Platform.environment['HOME'] ?? '/tmp';

    final xdgData =
        io.Platform.environment['XDG_DATA_HOME'] ?? '$home/.local/share';

    trashBaseDir = fs.directory('$xdgData/Trash');
    trashFilesDir = fs.directory('${trashBaseDir.path}/files');
    trashInfoDir = fs.directory('${trashBaseDir.path}/info');

    await trashBaseDir.create(recursive: true);
    await trashFilesDir.create(recursive: true);
    await trashInfoDir.create(recursive: true);

    _initialized = true;
  }
}
