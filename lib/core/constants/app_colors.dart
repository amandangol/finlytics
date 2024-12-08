import 'package:flutter/material.dart';

// Primary Color Palette
// A soothing and balanced palette with soft blues, grays, and subtle accents
class AppTheme {
  static const Color primaryColor = Color(0xFF4A90E2); // Soft Blue
  static const Color secondaryColor = Color(0xFFB3D1F4); // Light Blue
  static const Color accentColor = Color(0xFF50E3C2); // Soft Teal

  // Neutral Colors
  static const Color backgroundColor = Color(0xFFF0F4F8); // Light Grayish Blue
  static const Color surfaceColor = Colors.white;
  static const Color cardColor = Color(0xFFEBF0F4); // Lighter Gray for cards
  static const Color dividerColor =
      Color(0xFFCBD6E2); // Light Gray for dividers

  // Text Colors
  static const Color darkTextColor = Color(0xFF2C3E50); // Charcoal Gray
  static const Color lightTextColor = Color(0xFFFFFFFF); // White
  static const Color mutedTextColor = Color(0xFF95A5A6); // Muted gray text

  // Error and Warning Colors
  static const Color errorColor = Color(0xFFD32F2F); // Red
  static const Color warningColor = Color(0xFFFFA000); // Amber

  // Success and Info Colors
  static const Color successColor = Color(0xFF388E3C); // Green
  static const Color infoColor = Color(0xFF1976D2); // Blue

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primaryColor,
      secondaryColor,
    ],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      accentColor,
      secondaryColor,
    ],
  );

  // Shadows
  static const BoxShadow lightShadow = BoxShadow(
    color: Colors.black26,
    blurRadius: 8,
    offset: Offset(0, 4),
  );

  static const BoxShadow darkShadow = BoxShadow(
    color: Colors.black38,
    blurRadius: 10,
    offset: Offset(0, 6),
  );

  // Text Styles
  static final TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: darkTextColor,
    ),
    displayMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: darkTextColor,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: darkTextColor,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: mutedTextColor,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      color: mutedTextColor.withOpacity(0.8),
    ),
  );

  // Button Themes
  static final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    foregroundColor: lightTextColor,
    backgroundColor: primaryColor,
    shadowColor: Colors.black26,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  // App Theme Data
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceColor,
      elevation: 2,
      iconTheme: IconThemeData(color: darkTextColor),
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
      background: backgroundColor,
      surface: surfaceColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: elevatedButtonStyle,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: Color(0xFF121212),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF1B1B1B),
      elevation: 2,
      iconTheme: IconThemeData(color: lightTextColor),
      titleTextStyle: textTheme.displayMedium?.copyWith(color: lightTextColor),
      shadowColor: Colors.black45,
    ),
    cardColor: Color(0xFF1E1E1E),
    dividerColor: Colors.white24,
    textTheme: textTheme.copyWith(
      bodyLarge: textTheme.bodyLarge!.copyWith(color: lightTextColor),
      bodyMedium: textTheme.bodyMedium!.copyWith(color: lightTextColor),
    ),
    colorScheme: ColorScheme.fromSwatch(
      brightness: Brightness.dark,
      primarySwatch: Colors.blue,
    ).copyWith(
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
      background: Color(0xFF121212),
      surface: Color(0xFF1B1B1B),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: elevatedButtonStyle.copyWith(
        backgroundColor: MaterialStateProperty.all(primaryColor),
      ),
    ),
  );
}
