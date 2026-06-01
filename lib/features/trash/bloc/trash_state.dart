import 'package:equatable/equatable.dart';
import 'package:file/file.dart';

class TrashState extends Equatable {
  final bool loading;
  final String? error;
  final List<FileSystemEntity> trashItems;
  final bool operationSuccess;

  const TrashState({
    this.loading = false,
    this.error,
    this.trashItems = const [],
    this.operationSuccess = false,
  });

  TrashState copyWith({
    bool? loading,
    String? error,
    List<FileSystemEntity>? trashItems,
    bool? operationSuccess,
  }) {
    return TrashState(
      loading: loading ?? this.loading,
      error: error ?? this.error,
      trashItems: trashItems ?? this.trashItems,
      operationSuccess: operationSuccess ?? this.operationSuccess,
    );
  }

  @override
  List<Object?> get props => [loading, error, trashItems, operationSuccess];
}
