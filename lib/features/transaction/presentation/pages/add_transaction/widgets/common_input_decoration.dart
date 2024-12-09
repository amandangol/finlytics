import 'package:flutter/material.dart';
import '../../../../../../core/constants/app_colors.dart';

InputDecoration getCommonInputDecoration(
  BuildContext context, {
  required String labelText,
  required IconData prefixIcon,
  bool isDarkMode = false,
}) {
  final theme = Theme.of(context);
  return InputDecoration(
    labelText: labelText,
    labelStyle: theme.textTheme.bodyMedium?.copyWith(
      color: isDarkMode ? Colors.white70 : theme.textTheme.bodyMedium?.color,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: isDarkMode ? Colors.white54 : AppTheme.primaryColor,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: isDarkMode ? Colors.white30 : theme.hintColor,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: AppTheme.primaryColor,
        width: 2,
      ),
    ),
    prefixIcon: Icon(
      prefixIcon,
      color: isDarkMode ? Colors.white : AppTheme.primaryColor,
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
  );
}
