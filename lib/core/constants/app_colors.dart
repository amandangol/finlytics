import 'package:flutter/material.dart';

// Enhanced Color Palette with More Variety and Depth
class AppTheme {
  // Primary Color Family
  static const Color primaryColor = Color(0xFF3498DB); // Vibrant Blue
  static const Color primaryLightColor = Color(0xFF5DADE2); // Lighter Blue
  static const Color primaryDarkColor = Color(0xFF2874A6); // Dark Blue

  // Secondary Color Family
  static const Color secondaryColor = Color(0xFF2ECC71); // Bright Green
  static const Color secondaryLightColor = Color(0xFF58D68D); // Light Green
  static const Color secondaryDarkColor = Color(0xFF27AE60); // Dark Green

  // Accent Colors
  static const Color accentColor = Color(0xFFE74C3C); // Vibrant Red
  static const Color accentLightColor = Color(0xFFEC7063); // Light Red
  static const Color accentDarkColor = Color(0xFFC0392B); // Dark Red

  // Neutral Colors
  static const Color backgroundColor = Color(0xFFF4F6F7); // Light Gray
  static const Color surfaceColor = Color(0xFFFFFFFF); // Pure White
  static const Color cardColor = Color(0xFFF8F9F9); // Very Light Gray
  static const Color dividerColor = Color(0xFFE5E7E9); // Soft Gray

  // Text Colors
  static const Color darkTextColor = Color(0xFF2C3E50); // Deep Blue Gray
  static const Color lightTextColor = Color(0xFFFFFFFF); // White
  static const Color mutedTextColor = Color(0xFF7F8C8D); // Muted Gray

  // Semantic Colors
  static const Color errorColor = Color(0xFFD32F2F); // Strong Red
  static const Color warningColor = Color(0xFFF39C12); // Bright Orange
  static const Color successColor = Color(0xFF27AE60); // Confident Green
  static const Color infoColor = Color(0xFF3498DB); // Informative Blue

  // Gradient Variations
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, primaryLightColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondaryColor, secondaryLightColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Enhanced Shadows
  static const BoxShadow softShadow = BoxShadow(
    color: Colors.black12,
    blurRadius: 6,
    offset: Offset(0, 3),
  );

  static const BoxShadow deepShadow = BoxShadow(
    color: Colors.black26,
    blurRadius: 12,
    offset: Offset(0, 6),
  );

  // Comprehensive Text Theme
  static final TextTheme textTheme = TextTheme(
    displayLarge: const TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: darkTextColor,
      letterSpacing: 0.5,
    ),
    displayMedium: const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: darkTextColor,
      letterSpacing: 0.3,
    ),
    bodyLarge: const TextStyle(
      fontSize: 16,
      color: darkTextColor,
      height: 1.5,
    ),
    bodyMedium: const TextStyle(
      fontSize: 14,
      color: mutedTextColor,
      height: 1.4,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      color: mutedTextColor.withOpacity(0.7),
    ),
  );

  // Advanced Button Styles
  static final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    foregroundColor: lightTextColor,
    backgroundColor: primaryColor,
    shadowColor: Colors.black26,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  );

  // Light Theme Configuration
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceColor,
      elevation: 2,
      iconTheme: const IconThemeData(color: darkTextColor),
      titleTextStyle: textTheme.displayMedium,
      shadowColor: dividerColor,
    ),
    cardColor: cardColor,
    dividerColor: dividerColor,
    textTheme: textTheme,
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
      surface: surfaceColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: elevatedButtonStyle,
    ),
  );

  // Dark Theme Configuration
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryDarkColor,
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1F1F1F),
      elevation: 2,
      iconTheme: const IconThemeData(color: lightTextColor),
      titleTextStyle: textTheme.displayMedium?.copyWith(color: lightTextColor),
      shadowColor: Colors.black45,
    ),
    cardColor: const Color(0xFF1E1E1E),
    dividerColor: Colors.white24,
    textTheme: textTheme.copyWith(
      bodyLarge: textTheme.bodyLarge!.copyWith(color: lightTextColor),
      bodyMedium: textTheme.bodyMedium!.copyWith(color: lightTextColor),
    ),
    colorScheme: ColorScheme.fromSwatch(
      brightness: Brightness.dark,
      primarySwatch: Colors.blueGrey,
    ).copyWith(
      primary: primaryDarkColor,
      secondary: secondaryDarkColor,
      error: errorColor,
      surface: const Color(0xFF1F1F1F),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: elevatedButtonStyle.copyWith(
        backgroundColor: WidgetStateProperty.all(primaryDarkColor),
      ),
    ),
  );
}
