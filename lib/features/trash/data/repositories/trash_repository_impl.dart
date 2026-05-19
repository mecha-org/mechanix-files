import 'dart:io';

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:files/features/trash/services/trash_path_service.dart';
import 'package:files/features/trash/data/repositories/trash_repository.dart';

class TrashRepositoryImpl implements TrashRepository {
  final FileSystem _fs;

  TrashRepositoryImpl({FileSystem? fs}) : _fs = fs ?? const LocalFileSystem();

  @override
  Future<void> moveToTrash(List<String> paths) async {
    final result = await Process.run('gio', ['trash', ...paths]);

    if (result.exitCode != 0) {
      // fallback to per-file handling
      for (final path in paths) {
        await Process.run('gio', ['trash', path]);
      }
    }
    return;
  }

  @override
  Future<List<FileSystemEntity>> getTrashItems() async {
    final entities =
        _fs.directory(TrashPathsService.trashFilesDir.path).listSync().toList();

    entities.sort((a, b) {
      final aStat = a.statSync();
      final bStat = b.statSync();

      return bStat.modified.compareTo(aStat.modified);
    });

    return entities;
  }
}
