import 'dart:async';

import 'package:files/core/theme/app_theme.dart';
import 'package:files/core/utils/app_logger.dart';
import 'package:files/core/widgets/custom_button.dart';
import 'package:files/core/widgets/middle_ellipsis_text.dart';
import 'package:files/core/widgets/notification/custom_notification.dart';
import 'package:files/features/files_explorer/blocs/file_boc.dart';
import 'package:files/features/files_explorer/blocs/file_event.dart';
import 'package:files/features/files_explorer/blocs/file_state.dart';
import 'package:files/features/files_explorer/controllers/file_manager_controller.dart';
import 'package:files/features/files_explorer/presentation/commons.dart';
import 'package:files/features/files_explorer/presentation/file_explorer.dart';
import 'package:files/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;

class FileConflict {
  final String path;
  final String fileName;
  final String destination;

  const FileConflict({
    required this.path,
    required this.fileName,
    required this.destination,
  });
}

class PasteHandler {
  static Future<void> handlePaste({
    required BuildContext context,
    required FilesState state,
    required FileManagerController controller,
    required VoidCallback reload,
    String? moveFilepath,
  }) async {
    final bloc = context.read<FilesBloc>();
    final targetPath = controller.getPathNotifier.value;
    final folderName = targetPath.split('/').last;

    /// ---------------- Single item FLOW ----------------
    if (moveFilepath != null && moveFilepath.isNotEmpty) {
      final itemName = p.basename(moveFilepath);

      final completer = Completer<void>();

      bloc.add(
        Move(
          sourcePaths: [moveFilepath],
          destinationPath: targetPath,
          completer: completer,
        ),
      );

      await completer.future;

      if (!context.mounted) return;

      CustomNotification.show(
        context: context,
        type: NotificationType.success,
        message: "Moved $itemName to $folderName",
      );

      return;
    }

    /// ---------------- MOVE FLOW ----------------
    if (state.isMoveMode) {
      final movePathCount = state.movedPaths.length;
      final hasInvalidMove = state.movedPaths.any((sourcePath) {
        final normalizedSource = p.normalize(sourcePath);
        final normalizedTarget = p.normalize(targetPath);

        return normalizedSource == normalizedTarget ||
            p.isWithin(normalizedSource, normalizedTarget);
      });

      if (hasInvalidMove) {
        await Future.delayed(const Duration(milliseconds: 200));

        if (!context.mounted) return;
        await showInvalidMoveSheet(
          context: context,
          movePathCount: movePathCount,
        );
        return;
      }

      final completer = Completer<void>();
      bloc.add(
        Move(
          sourcePaths: state.movedPaths,
          destinationPath: targetPath,
          completer: completer,
        ),
      );

      await completer.future;
      if (!context.mounted) return;

      bloc.add(CancelMoveMode());
      reload();

      CustomNotification.show(
        context: context,
        type: NotificationType.success,
        message:
            "Moved $movePathCount item${movePathCount > 1 ? 's' : ''} to $folderName",
      );

      return;
    }

    /// ---------------- COPY FLOW ----------------
    if (state.isCopyMode) {
      final completer = Completer<void>();

      bloc.add(
        Copy(
          sourcePaths: state.copiedPaths,
          destinationPath: targetPath,
          controller: controller,
          completer: completer,
        ),
      );

      await completer.future;

      if (!context.mounted) return;

      bloc.add(CancelCopyMode());

      reload();
      final explorerState =
          context.findAncestorStateOfType<FileExplorerPageState>();

      explorerState?.closePanel();
      explorerState?.modeNotifier.value = ExplorerMode.browsing;

      return;
    }
  }

  static Future<void> showInvalidMoveSheet({
    required BuildContext context,
    required int movePathCount,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.onSurfaceVariantDark,
          ),
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 16,
            top: 32,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("You cannot move a file over itself"),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        label: AppLocalizations.of(context)!.cancel,
                        backgroundColor: AppColors.onSurfaceVariantDark,
                        textColor: AppColors.onSurface,
                        borderRadius: 0,
                        onPressed: () {
                          context.read<FilesBloc>().add(CancelMoveMode());

                          Navigator.pop(sheetContext);
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: CustomButton(
                        label:
                            movePathCount > 1
                                ? AppLocalizations.of(context)!.skipAll
                                : AppLocalizations.of(context)!.skip,
                        backgroundColor: AppColors.onSurface,
                        textColor: AppColors.surface,
                        borderRadius: 0,
                        onPressed: () {
                          Navigator.pop(sheetContext);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<void> handleConflictsSequentially(
    BuildContext context,
    List<FileConflict> conflicts,
  ) async {
    final filesBloc = context.read<FilesBloc>();

    for (final conflict in conflicts) {
      if (!context.mounted) return;

      final strategy = await showModalBottomSheet<ConflictResolutionStrategy>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) {
          return ClipPath(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.backgroundVariant,
              ),
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 16,
                top: 32,
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final fileStyle = confirmationDialogBoldStyle(context);
                        final suffixStyle = confirmationDialogRegularStyle(
                          context,
                        );
                        const suffix = ' already exists';

                        // Measure suffix width
                        final suffixWidth = textWidth(suffix, suffixStyle);

                        // Remaining width for filename
                        final availableWidth = (constraints.maxWidth -
                                suffixWidth)
                            .clamp(0.0, double.infinity);

                        final truncatedName = middleEllipsisString(
                          conflict.fileName,
                          availableWidth,
                          fileStyle,
                        );

                        return RichText(
                          maxLines: 1,
                          text: TextSpan(
                            children: [
                              TextSpan(text: truncatedName, style: fileStyle),
                              TextSpan(text: suffix, style: suffixStyle),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Would you like to replace?',
                      style: TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            label: AppLocalizations.of(context)!.cancel,
                            backgroundColor: AppColors.onSurfaceVariantDark,
                            textColor: AppColors.onSurface,
                            borderRadius: 0,
                            onPressed: () {
                              totalMovedCount--;

                              Navigator.pop(
                                sheetContext,
                                ConflictResolutionStrategy.skip,
                              );
                            },
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: CustomButton(
                            label: AppLocalizations.of(context)!.replace,
                            backgroundColor: AppColors.onSurface,
                            textColor: AppColors.surface,
                            borderRadius: 0,
                            onPressed: () {
                              Navigator.pop(
                                sheetContext,
                                ConflictResolutionStrategy.replace,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );

      if (strategy == null) continue;

      filesBloc.add(
        ContinueMoveWithConflictResolution(
          sourcePaths: [conflict.path],
          destinationPath: conflict.destination,
          strategy: strategy,
        ),
      );

      try {
        await filesBloc.stream
            .firstWhere(
              (s) =>
                  (!s.conflictingPaths.contains(conflict.path) && !s.loading) ||
                  (!s.isMoveMode),
            )
            .timeout(const Duration(seconds: 5));
      } catch (e) {
        AppLogger.i(
          'Warning: waiting for conflict resolution timed out for ${conflict.fileName}: $e',
        );
      }
    }
  }
}

class ConflictResolutionBottomSheet extends StatelessWidget {
  final List<String> conflictingPaths;
  final String destinationPath;
  final FileManagerController controller;

  const ConflictResolutionBottomSheet({
    super.key,
    required this.conflictingPaths,
    required this.destinationPath,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final fileName = p.basename(conflictingPaths.first);

    return ClipPath(
      child: Container(
        decoration: const BoxDecoration(color: AppColors.backgroundVariant),
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 16,
          top: 32,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  const suffixText = ' already exists';
                  final suffixStyle = confirmationDialogRegularStyle(context);
                  final nameStyle = confirmationDialogBoldStyle(context);
                  final suffixWidth = textWidth(suffixText, suffixStyle);
                  final availableForName = constraints.maxWidth - suffixWidth;
                  final truncatedName = middleEllipsisString(
                    fileName,
                    availableForName,
                    nameStyle,
                  );

                  return RichText(
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    text: TextSpan(
                      children: [
                        TextSpan(text: truncatedName, style: nameStyle),
                        TextSpan(text: suffixText, style: suffixStyle),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              const Text(
                'Would you like to replace?',
                style: TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      label: AppLocalizations.of(context)!.cancel,
                      backgroundColor: AppColors.onSurfaceVariantDark,
                      textColor: AppColors.onSurface,
                      borderRadius: 0,
                      onPressed: () {
                        context.read<FilesBloc>().add(
                          ContinueCopyWithConflictResolution(
                            sourcePaths: conflictingPaths,
                            destinationPath: destinationPath,
                            strategy: ConflictResolutionStrategy.skip,
                            controller: controller,
                          ),
                        );
                        Navigator.pop(context);
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: CustomButton(
                      label: AppLocalizations.of(context)!.replace,
                      backgroundColor: AppColors.onSurface,
                      textColor: AppColors.surface,
                      borderRadius: 0,
                      onPressed: () {
                        context.read<FilesBloc>().add(
                          ContinueCopyWithConflictResolution(
                            sourcePaths: conflictingPaths,
                            destinationPath: destinationPath,
                            strategy: ConflictResolutionStrategy.replace,
                            controller: controller,
                          ),
                        );
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
