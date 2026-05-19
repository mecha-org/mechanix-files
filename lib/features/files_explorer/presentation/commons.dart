import 'dart:ui' as ui;

import 'package:files/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

TextStyle confirmationDialogRegularStyle(BuildContext context) =>
    const TextStyle(
      color: AppColors.onSurface,
      fontSize: 24,
      fontWeight: FontWeight.w400,
    );

TextStyle confirmationDialogBoldStyle(BuildContext context) => const TextStyle(
  color: AppColors.onSurface,
  fontSize: 24,
  fontWeight: FontWeight.w600,
);

double textWidth(String text, TextStyle style) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    maxLines: 1,
    textDirection: ui.TextDirection.ltr,
  )..layout();

  return painter.width;
}
