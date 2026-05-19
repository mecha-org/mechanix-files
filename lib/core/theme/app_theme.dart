import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color.fromARGB(255, 0, 0, 0);
  static const Color surface = Color.fromARGB(255, 0, 0, 0);
  static const Color onSecondary = Color(0xFF000000);
  static const Color onBackground = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFFDDDDDD);
  static const Color onSurfaceVariant = Color(0xFFADADAD);
  static const Color onSurfaceVariantDark = Color(0xFF636363);
  static const Color backgroundVariant = Color(0xFF212121);
  static const Color backgroundVariantDark = Color(0xFF151515);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
      ),
    );
  }
}
