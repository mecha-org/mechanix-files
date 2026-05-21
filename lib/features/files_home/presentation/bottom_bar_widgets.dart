import 'package:files/core/theme/app_theme.dart';
import 'package:files/core/constants/icons.dart';
import 'package:files/core/widgets/bottom_bar/bottom_bar.dart';
import 'package:flutter/material.dart';

class NormalBottomBar extends StatelessWidget {
  const NormalBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
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
}

class PasteDestinationBottomBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onMenu;
  final VoidCallback? onConfirm;

  const PasteDestinationBottomBar({
    super.key,
    required this.onBack,
    required this.onMenu,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
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
          onPressed: onConfirm,
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
}
