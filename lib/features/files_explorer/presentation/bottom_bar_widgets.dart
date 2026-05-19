import 'package:files/core/theme/app_theme.dart';
import 'package:files/core/constants/icons.dart';
import 'package:files/core/widgets/bottom_bar/bottom_bar.dart';
import 'package:files/features/files_explorer/controllers/file_manager_controller.dart';
import 'package:files/features/files_explorer/presentation/file_details_dialog.dart';
import 'package:files/features/files_explorer/presentation/file_explorer.dart';
import 'package:files/features/files_explorer/presentation/folder_actions_menu.dart';
import 'package:files/features/files_explorer/presentation/multiselect_actions_menu.dart';
import 'package:files/features/files_explorer/presentation/paste_menu.dart';
import 'package:flutter/material.dart';

Widget buildBottomPanel({
  required ExplorerBottomPanel activePanel,
  required FileManagerController controller,
  required FileExplorerPageState state,
  required VoidCallback closePanel,
  String? infoPath,
  String? selectedItemPath,
}) {
  switch (activePanel) {
    case ExplorerBottomPanel.menu:
      return FolderActionsMenu(
        key: const ValueKey('menu'),
        controller: controller,
        state: state,
        closeFolderActionsSheet: closePanel,
      );

    case ExplorerBottomPanel.info:
      return infoPath != null
          ? FileDetailsDialog(
            key: const ValueKey('info'),
            path: infoPath,
            onClose: closePanel,
          )
          : const SizedBox.shrink();

    case ExplorerBottomPanel.selectMenu:
      return MultiselectActionsMenu(
        key: const ValueKey('selectMenu'),
        controller: controller,
        state: state,
        closeMultiselectActionsSheet: closePanel,
      );

    case ExplorerBottomPanel.pasteMenu:
      return PasteActionsMenu(
        key: const ValueKey('pasteMenu'),
        controller: controller,
        state: state,
        closePasteActionsSheet: closePanel,
      );

    case ExplorerBottomPanel.none:
      return const SizedBox.shrink();
  }
}

Widget buildBottomBarForMode(ExplorerMode mode, context) {
  switch (mode) {
    case ExplorerMode.browsing:
      return buildNormalBottomBar(context);

    case ExplorerMode.selecting:
      return buildSelectionBottomBar(context);

    case ExplorerMode.moving:
      return buildPasteDestinationBottomBar(context, false);

    case ExplorerMode.copying:
      return buildPasteDestinationBottomBar(context, true);
  }
}

Widget buildSelectionBottomBar(BuildContext context) {
  final state = context.findAncestorStateOfType<FileExplorerPageState>();

  if (state == null) {
    return const SizedBox.shrink();
  }

  return ValueListenableBuilder<Set<String>>(
    valueListenable: state.selectedPathsNotifier,
    builder: (context, selectedPaths, _) {
      final hasSelection = selectedPaths.isNotEmpty;

      return BottomBar(
        key: const ValueKey('selection_bottom_bar'),

        leading: IconButton(
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          icon: const Icon(Icons.close, color: AppColors.onSurface, size: 24),
          onPressed: state.clearSelection,
        ),

        center: [
          /// Select All
          IconButton(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            icon: Image.asset(
              FileIcons.checkCircle,
              width: 24,
              height: 24,
              color: AppColors.onSurface,
            ),
            onPressed: state.handleSelectAll,
          ),

          /// Copy
          IconButton(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            icon: Image.asset(
              FileIcons.copy,
              width: 24,
              height: 24,
              color:
                  hasSelection
                      ? AppColors.onSurface
                      : AppColors.onSurfaceVariantDark,
            ),
            onPressed: hasSelection ? state.handleCopy : null,
          ),

          /// Move
          IconButton(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            icon: Image.asset(
              FileIcons.move,
              width: 24,
              height: 24,
              color:
                  hasSelection
                      ? AppColors.onSurface
                      : AppColors.onSurfaceVariantDark,
            ),
            onPressed: hasSelection ? state.handleMove : null,
          ),
        ],

        trailing: [
          IconButton(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            icon: Image.asset(
              FileIcons.moreVert,
              width: 24,
              height: 24,
              color: AppColors.onSurface,
            ),
            onPressed: state.openMenu,
          ),
        ],
      );
    },
  );
}

Widget buildNormalBottomBar(BuildContext context) {
  final state = context.findAncestorStateOfType<FileExplorerPageState>();

  return BottomBar(
    key: const ValueKey('normal_bottom_bar'),

    leading: IconButton(
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      icon: Image.asset(
        FileIcons.back,
        width: 24,
        height: 24,
        color: AppColors.onSurface,
      ),
      onPressed: () {
        if (state?.isHomePageDir == true) {
          state?.homeNavigation();
        } else {
          state?.handleBack();
        }
      },
    ),

    trailing: [
      IconButton(
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        icon: Image.asset(
          FileIcons.search,
          width: 24,
          height: 24,
          color: AppColors.onSurface,
        ),
        onPressed: state?.onSearchPressed,
      ),

      IconButton(
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        icon: Image.asset(
          FileIcons.moreVert,
          width: 24,
          height: 24,
          color: AppColors.onSurface,
        ),
        onPressed: state?.openMenu,
      ),
    ],
  );
}

Widget buildPasteDestinationBottomBar(BuildContext context, bool isCopyMode) {
  final state = context.findAncestorStateOfType<FileExplorerPageState>();
  return BottomBar(
    leading: IconButton(
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      icon: Image.asset(
        FileIcons.back,
        width: 24,
        height: 24,
        color: AppColors.onSurface,
      ),
      onPressed: () {
        if (state?.isHomePageDir == true) {
          state?.homeNavigation();
        } else {
          state?.handleBack();
        }
      },
    ),

    trailing: [
      IconButton(
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        icon: Image.asset(
          FileIcons.check,
          width: 24,
          height: 24,
          color: AppColors.onSurface,
        ),
        onPressed: () {
          state?.handlePaste();
          state?.modeNotifier.value = ExplorerMode.browsing;
        },
      ),

      IconButton(
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        icon: Image.asset(
          FileIcons.moreVert,
          width: 24,
          height: 24,
          color: AppColors.onSurface,
        ),
        onPressed: state?.openMenu,
      ),
    ],
  );
}
