import 'package:file/file.dart';
import 'package:file/local.dart';

class AppFileSystem {
  AppFileSystem._();

  static FileSystem instance = const LocalFileSystem();
}
