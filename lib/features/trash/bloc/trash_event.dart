import 'dart:async';

import 'package:equatable/equatable.dart';

abstract class TrashEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class MoveToTrash extends TrashEvent {
  final List<String> paths;
  final Completer<void>? completer;

  MoveToTrash(this.paths, {this.completer});

  @override
  List<Object?> get props => [paths];
}

class RestoreFromTrash extends TrashEvent {
  final String trashPath;

  RestoreFromTrash(this.trashPath);

  @override
  List<Object?> get props => [trashPath];
}

class EmptyTrash extends TrashEvent {}
