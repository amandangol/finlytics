import 'package:flutter/material.dart';
import '../../../../../../core/constants/app_colors.dart';

InputDecoration getCommonInputDecoration(
  BuildContext context, {
  required String labelText,
  final IconData? prefixIcon,
  Color? fillColor,
}) {
  return InputDecoration(
    labelText: labelText,
    prefixIcon: Icon(prefixIcon, color: AppTheme.primaryColor),
    fillColor: fillColor ?? AppTheme.cardColor.withOpacity(0.5),
    filled: true,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: AppTheme.primaryColor.withOpacity(0.3),
        width: 1.5,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: AppTheme.primaryColor,
        width: 2,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: Colors.red,
        width: 1.5,
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: Colors.red,
        width: 2,
      ),
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
  );
}
