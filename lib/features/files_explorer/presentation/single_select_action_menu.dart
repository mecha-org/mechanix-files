import 'package:files/core/theme/app_theme.dart';
import 'package:files/core/constants/icons.dart';
import 'package:files/core/widgets/menu_row.dart';
import 'package:files/core/widgets/middle_ellipsis_text.dart';
import 'package:files/features/files_explorer/blocs/file_boc.dart';
import 'package:files/features/files_explorer/blocs/file_event.dart';
import 'package:files/features/files_explorer/controllers/file_manager_controller.dart';
import 'package:files/features/files_explorer/presentation/file_explorer.dart';
import 'package:files/features/files_home/data/models/file_item.dart';
import 'package:files/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;

class SingleSelectActionsMenu extends StatelessWidget {
  final String path;
  final FileManagerController controller;
  final FileExplorerPageState state;
  final VoidCallback closeSingleSelectActionsSheet;

  const SingleSelectActionsMenu({
    super.key,
    required this.path,
    required this.controller,
    required this.state,
    required this.closeSingleSelectActionsSheet,
  });

  @override
  Widget build(BuildContext context) {
    final fileItem = FileItem(
      name: p.basename(path),
      type: p.extension(path).isEmpty ? 'dir' : p.extension(path),
      modified: DateTime.now(),
    );

    return Material(
      color: const Color(0xFF1F1F1F),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                /// Left side (icon + text)
                Expanded(
                  child: Row(
                    children: [
                      Image.asset(
                        fileItem.iconPath,
                        width: 20,
                        height: 20,
                        color: AppColors.onSurfaceVariant,
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            const textStyle = TextStyle(
                              fontSize: 20,
                              color: AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.w300,
                            );

                            return Text(
                              middleEllipsisString(
                                fileItem.name,
                                constraints.maxWidth,
                                textStyle,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                              style: textStyle,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                /// Right side (fixed size)
                IconButton(
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  icon: const Icon(Icons.close, color: AppColors.onSurface),
                  onPressed: () {
                    closeSingleSelectActionsSheet();
                    state.selectedPathsNotifier.value = {};
                  },
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color.fromARGB(255, 53, 52, 52)),

          MenuRow(
            iconPath: FileIcons.copy,
            title: AppLocalizations.of(context)!.copyTo,
            onTap: () {
              closeSingleSelectActionsSheet();
              state.handleCopy();
              state.selectedPathsNotifier.value = {};
            },
          ),

          MenuRow(
            iconPath: FileIcons.move,
            title: AppLocalizations.of(context)!.moveTo,
            onTap: () {
              closeSingleSelectActionsSheet();
              state.handleMove();
              state.selectedPathsNotifier.value = {};
            },
          ),

          MenuRow(
            iconPath: FileIcons.rename,
            title: AppLocalizations.of(context)!.rename,
            onTap: () {
              closeSingleSelectActionsSheet();
              state.showRenameSheet(initialName: fileItem.name);
              state.selectedPathsNotifier.value = {};
            },
          ),

          MenuRow(
            iconPath: FileIcons.createFolder,
            title: AppLocalizations.of(context)!.newFolderWithSingleItem,
            onTap: () {
              closeSingleSelectActionsSheet();
              state.handleCreateFolderWithItems(path);
              state.selectedPathsNotifier.value = {};
            },
          ),

          MenuRow(
            iconPath: FileIcons.info,
            title: AppLocalizations.of(context)!.fileInfo,
            onTap: () {
              closeSingleSelectActionsSheet();
              context.read<FilesBloc>().add(FetchFileDetails(path));
              state.showInfo(path);
              state.selectedPathsNotifier.value = {};
            },
          ),

          MenuRow(
            iconPath: FileIcons.delete,
            title: AppLocalizations.of(context)!.moveToTrash,
            onTap: () {
              closeSingleSelectActionsSheet();
              state.handleMoveToTrash();
              state.selectedPathsNotifier.value = {};
            },
            enabled: state.selectedPathsNotifier.value.isNotEmpty,
          ),
        ],
      ),
    );
  }
}

void showSingleSelectActionsSheet(
  BuildContext context, {
  required String path,
  required FileManagerController controller,
  required FileExplorerPageState state,
}) {
  state.selectedPathsNotifier.value = {path};

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return SingleSelectActionsMenu(
        path: path,
        controller: controller,
        state: state,
        closeSingleSelectActionsSheet: () {
          Navigator.pop(context);
        },
      );
    },
  );
}
