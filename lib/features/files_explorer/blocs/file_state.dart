import 'package:equatable/equatable.dart';
import 'package:file/file.dart';

class FilesState extends Equatable {
  final bool loading;
  final List<FileSystemEntity> fileSystemList;
  final String? error;

  final bool isCopyMode;
  final List<String> copiedPaths;
  final List<String> conflictingPaths;
  final String conflictDestinationPath;

  final bool isMoveMode;
  final List<String> movedPaths;

  final String currentSortBy;
  final bool isAscending;

  final FileStat? fileDetails;
  final bool showHiddenFiles;
  final int currentPage;
  final bool hasMorePages;

  const FilesState({
    this.loading = false,
    this.fileSystemList = const [],
    this.error,
    this.isCopyMode = false,
    this.copiedPaths = const [],
    this.conflictingPaths = const [],
    required this.conflictDestinationPath,
    this.isMoveMode = false,
    this.movedPaths = const [],
    this.currentSortBy = '',
    this.isAscending = false,
    this.fileDetails,
    this.showHiddenFiles = false,
    this.currentPage = 1,
    this.hasMorePages = true,
  });

  FilesState copyWith({
    bool? loading,
    List<FileSystemEntity>? fileSystemList,
    String? error,
    bool? isCopyMode,
    List<String>? copiedPaths,
    List<String>? conflictingPaths,
    String? conflictDestinationPath,
    bool? isMoveMode,
    List<String>? movedPaths,
    String? currentSortBy,
    bool? isAscending,
    FileStat? fileDetails,
    bool? showHiddenFiles,
    int? currentPage,
    bool? hasMorePages,
  }) {
    return FilesState(
      loading: loading ?? this.loading,
      fileSystemList: fileSystemList ?? this.fileSystemList,
      error: error ?? this.error,
      isCopyMode: isCopyMode ?? this.isCopyMode,
      copiedPaths: copiedPaths ?? this.copiedPaths,
      isMoveMode: isMoveMode ?? this.isMoveMode,
      movedPaths: movedPaths ?? this.movedPaths,
      currentSortBy: currentSortBy ?? this.currentSortBy,
      isAscending: isAscending ?? this.isAscending,
      fileDetails: fileDetails ?? this.fileDetails,
      showHiddenFiles: showHiddenFiles ?? this.showHiddenFiles,
      conflictingPaths: conflictingPaths ?? this.conflictingPaths,
      conflictDestinationPath:
          conflictDestinationPath ?? this.conflictDestinationPath,
      currentPage: currentPage ?? this.currentPage,
      hasMorePages: hasMorePages ?? this.hasMorePages,
    );
  }

  @override
  List<Object?> get props => [
    loading,
    fileSystemList,
    isCopyMode,
    copiedPaths,
    error,
    isMoveMode,
    movedPaths,
    currentSortBy,
    fileDetails,
    conflictingPaths,
    conflictDestinationPath,
    currentPage,
    hasMorePages,
  ];
}
