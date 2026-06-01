import 'package:file/file.dart';

abstract class TrashRepository {
  Future<void> moveToTrash(List<String> paths);

  Future<List<FileSystemEntity>> getTrashItems();
}
