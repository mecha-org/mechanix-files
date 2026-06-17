import 'dart:io';

class AppPaths {
  static String homeDir = Platform.environment['HOME'] ?? '/home/mecha';
  static String downloadsDir =
      '${Platform.environment['HOME'] ?? '/home/mecha'}/Downloads';
  static String documentsDir =
      '${Platform.environment['HOME'] ?? '/home/mecha'}/Documents';

  /// Virtual recent page (not filesystem path)
  static const String recentDir = '/recent';

  static String trashDir =
      '${Platform.environment['HOME'] ?? '/home/mecha'}/.local/share/Trash/files';

  /// PDFium native library
  static const String pdfiumModulePath = '/usr/lib64/libpdfium.so';
}
