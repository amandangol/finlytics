import 'package:flutter/material.dart';

class ErrorUtils {
  static void showSnackBar({
    required BuildContext context,
    required String message,
    bool isError = true,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onVisible,
    Color? color,
    IconData? icon,
  }) {
    // Remove any existing SnackBars
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon!),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        onVisible: onVisible,
      ),
    );
  }

  // Handle specific Firebase Authentication errors
  static String getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-email':
        return 'Invalid email format';
      case 'email-already-in-use':
        return 'Email already in use';
      case 'weak-password':
        return 'Password is too weak';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'operation-not-allowed':
        return 'Sign-in method not allowed';
      case 'invalid-credential':
        return 'Invalid login credentials. Please check and try again';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}
