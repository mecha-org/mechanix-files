import 'package:flutter/material.dart';

class SectionItem {
  final String title;
  final TextStyle? titleStyle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool disabled;

  const SectionItem({
    required this.title,
    this.titleStyle,
    this.leading,
    this.trailing,
    this.onTap,
    this.disabled = false,
  });
}
