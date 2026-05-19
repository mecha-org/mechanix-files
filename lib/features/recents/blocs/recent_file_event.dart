import 'package:equatable/equatable.dart';

abstract class RecentFilesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadRecentFiles extends RecentFilesEvent {}

class AddToRecentFiles extends RecentFilesEvent {
  final String path;
  AddToRecentFiles(this.path);
}

class SearchFilesInDirectory extends RecentFilesEvent {
  final String path;
  final String query;

  SearchFilesInDirectory(this.path, this.query);
}

class ClearSearchResults extends RecentFilesEvent {}

class RemoveRecentEntities extends RecentFilesEvent {
  final List<String> entitiesPath;

  RemoveRecentEntities(this.entitiesPath);
}

class SortRecentFiles extends RecentFilesEvent {
  final String sortBy;
  final bool isAscending;
  SortRecentFiles(this.sortBy, this.isAscending);
}
