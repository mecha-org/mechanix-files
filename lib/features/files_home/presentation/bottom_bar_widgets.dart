import 'package:files/core/theme/app_theme.dart';
import 'package:files/core/constants/icons.dart';
import 'package:files/core/widgets/bottom_bar/bottom_bar.dart';
import 'package:flutter/material.dart';

Widget buildNormalBottomBar(BuildContext context) {
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
        // TODO: Handle close app
      },
    ),
  );
}

Widget buildPasteDestinationBottomBar({
  required VoidCallback onBack,
  required VoidCallback onMenu,
}) {
  return BottomBar(
    leading: IconButton(
      icon: Image.asset(
        FileIcons.back,
        width: 24,
        height: 24,
        color: AppColors.onSurface,
      ),
      onPressed: onBack,
    ),

    trailing: [
      IconButton(
        icon: Image.asset(
          FileIcons.check,
          width: 24,
          height: 24,
          color: AppColors.onSurfaceVariantDark,
        ),
        onPressed: null,
      ),
      IconButton(
        icon: Image.asset(
          FileIcons.moreVert,
          width: 24,
          height: 24,
          color: AppColors.onSurface,
        ),
        onPressed: onMenu,
      ),
    ],
  );
}
