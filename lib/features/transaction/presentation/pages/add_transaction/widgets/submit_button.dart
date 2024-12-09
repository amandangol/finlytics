import 'package:flutter/material.dart';
import '../../../../../../core/constants/app_colors.dart';

class SubmitButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  const SubmitButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: child,
    );
  }
}
