import 'package:file/file.dart';
import 'package:files/features/files_explorer/controllers/file_manager_controller.dart';
import 'package:files/features/recents/data/models/recent_files.dart';

abstract class RecentFilesRepository {
  Future<List<RecentFile>> getRecentFiles();

  Future<void> addRecentFile(String path);

  Future<void> clear();

  Future<void> removeRecentFile(List<String> entitiesPath);

  Future getSortedFiles({
    required List<FileSystemEntity> files,
    required SortBy sortBy,
    required bool ascending,
  });
}
