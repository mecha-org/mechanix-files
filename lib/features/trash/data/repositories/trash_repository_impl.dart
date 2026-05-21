import 'dart:io';

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:files/features/trash/services/trash_path_service.dart';
import 'package:files/features/trash/data/repositories/trash_repository.dart';

class TrashRepositoryImpl implements TrashRepository {
  final FileSystem _fs;

  TrashRepositoryImpl({FileSystem? fs}) : _fs = fs ?? const LocalFileSystem();

  Future<void> _ensureTrashInitialized() async {
    await TrashPathsService.init();
  }

  @override
  Future<void> moveToTrash(List<String> paths) async {
    await _ensureTrashInitialized();

    final result = await Process.run('gio', ['trash', ...paths]);

    if (result.exitCode != 0) {
      for (final path in paths) {
        await Process.run('gio', ['trash', path]);
      }
    }
  }

  @override
  Future<List<FileSystemEntity>> getTrashItems() async {
    await _ensureTrashInitialized();

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
