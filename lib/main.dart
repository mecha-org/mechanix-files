import 'dart:io';

import 'package:mechanix_files/core/constants/app_routes.dart';
import 'package:mechanix_files/core/theme/app_theme.dart';
import 'package:mechanix_files/features/files_explorer/blocs/file_boc.dart';
import 'package:mechanix_files/features/files_explorer/blocs/file_event.dart';
import 'package:mechanix_files/features/files_explorer/data/models/app_settings.dart';
import 'package:mechanix_files/features/files_explorer/data/repositories/app_settings_repository.dart';
import 'package:mechanix_files/features/files_explorer/data/repositories/app_settings_repository_impl.dart';
import 'package:mechanix_files/features/files_explorer/data/repositories/file_repository.dart';
import 'package:mechanix_files/features/files_explorer/data/repositories/file_repository_impl.dart';
import 'package:mechanix_files/features/files_home/presentation/files_home.dart';
import 'package:mechanix_files/features/recents/blocs/recent_file_event.dart';
import 'package:mechanix_files/features/recents/blocs/recent_files_bloc.dart';
import 'package:mechanix_files/features/recents/data/models/recent_files.dart';
import 'package:mechanix_files/features/recents/data/repositories/recent_files_repository.dart';
import 'package:mechanix_files/features/recents/data/repositories/recent_files_repository_impl.dart';
import 'package:mechanix_files/features/trash/bloc/trash_bloc.dart';
import 'package:mechanix_files/features/trash/data/repositories/trash_repository.dart';
import 'package:mechanix_files/features/trash/data/repositories/trash_repository_impl.dart';
import 'package:mechanix_files/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import 'package:mechanix_files/core/utils/app_file_system.dart';
import 'package:show_fps/show_fps.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Hive.registerAdapter(AppSettingsAdapter());
  Hive.registerAdapter(RecentFileAdapter());

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<FileRepository>(
          create: (_) => FileRepositoryImpl(fs: AppFileSystem.instance),
        ),

        RepositoryProvider<RecentFilesRepository>(
          create: (_) => RecentFilesRepositoryImpl(),
        ),

        RepositoryProvider<AppSettingsRepository>(
          create: (_) => AppSettingsRepositoryImpl(),
        ),

        RepositoryProvider<TrashRepository>(
          create: (_) => TrashRepositoryImpl(fs: AppFileSystem.instance),
        ),
      ],

      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create:
                (context) => FilesBloc(
                  fileRepository: context.read<FileRepository>(),
                  appSettingsRepository: context.read<AppSettingsRepository>(),
                )..add(InitializeFiles()),
          ),
          BlocProvider(
            create:
                (context) => RecentFilesBloc(
                  recentFilesRepository: context.read<RecentFilesRepository>(),
                  appSettingsRepository: context.read<AppSettingsRepository>(),
                )..add(LoadRecentFiles()),
          ),
          BlocProvider(
            create:
                (context) =>
                    TrashBloc(trashRepository: context.read<TrashRepository>()),
          ),
        ],

        child: const FilesApp(),
      ),
    ),
  );
}

class FilesApp extends StatefulWidget {
  const FilesApp({super.key});

  @override
  State<FilesApp> createState() => _FilesAppState();
}

class _FilesAppState extends State<FilesApp> {
  // Native side (elinux/runner/main.cc) exposes these two channels:
  // - initial_url_channel: pull — we ask for the cold-start path/URL once.
  //   Nothing is sent from C++ until we call it, so there's no race with
  //   engine/plugin startup.
  // - singleton_channel: push — C++ forwards a path/URL here whenever a
  //   second launch is redirected to this already-running instance.
  static const _initialUrlChannel = MethodChannel(
    'com.mechanix.files/initial_url',
  );
  static const _singletonChannel = BasicMessageChannel<dynamic>(
    'com.mechanix.files/singleton',
    StandardMessageCodec(),
  );

  final _navigatorKey = GlobalKey<NavigatorState>();

  String _openPath = '';

  @override
  void initState() {
    super.initState();
    _listenForForwardedPaths();
    _fetchInitialPath();
  }

  Future<void> _fetchInitialPath() async {
    String? path;
    try {
      path = await _initialUrlChannel.invokeMethod<String>('getInitialUrl');
      print("path initial: $path");
    } on PlatformException catch (e) {
      debugPrint('getInitialUrl failed: $e');
    } on MissingPluginException catch (e) {
      // Expected on platforms other than elinux where this channel
      // doesn't exist (e.g. running via `flutter run` on a dev host).
      debugPrint('getInitialUrl channel unavailable: $e');
    }

    // Fall back to the env-var mechanism for local/dev runs.
    path ??= _parseOpenPath();

    if (path.isNotEmpty && mounted) {
      setState(() => _openPath = path!);
    }
  }

  void _listenForForwardedPaths() {
    _singletonChannel.setMessageHandler((dynamic message) async {
      if (message is String && message.isNotEmpty) {
        _openPath = message;
        final segments = pathToSegments(message);
        // Re-push the file explorer route with the newly forwarded path.
        _navigatorKey.currentState?.popUntil((route) => route.isFirst);
        if (mounted) setState(() {});
      }
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final showFps = Platform.environment['SHOW_FPS'] == 'true';

    return MaterialApp(
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      builder:
          showFps
              ? (context, child) {
                return ShowFPS(
                  visible: showFps,
                  showChart: false,
                  child: child!,
                );
              }
              : null,
      theme: AppTheme.darkTheme,
      home: buildFileExplorerPage(context, _openPath),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routes: {
        AppRoutes.files:
            (context) => buildFileExplorerPage(context, _openPath),
      },
    );
  }

  Widget buildFileExplorerPage(BuildContext context, String openPath) {
    return FileHomePage(
      key: ValueKey(openPath),
      path: openPath.isNotEmpty ? pathToSegments(openPath) : const [],
    );
  }
}

String _parseOpenPath() {
  const compileTimeOpenPath = String.fromEnvironment(
    'MECHANIX_FILES_OPEN_PATH',
  );
  final runtimeOpenPath = Platform.environment['MECHANIX_FILES_OPEN_PATH'];
  return compileTimeOpenPath.isNotEmpty
      ? compileTimeOpenPath
      : (runtimeOpenPath ?? '');
}