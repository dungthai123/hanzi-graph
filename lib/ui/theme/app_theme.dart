import 'package:flutter/material.dart';

/// App theme configuration
class AppTheme {
  // Color scheme
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFB00020);

  // Chinese character specific colors
  static const Color hanziColor = Color(0xFF1A1A1A);
  static const Color pinyinColor = Color(0xFF666666);
  static const Color definitionColor = Color(0xFF333333);
  static const Color componentColor = Color(0xFF4CAF50);

  // Graph colors
  static const Color graphNodeColor = Color(0xFF2196F3);
  static const Color graphEdgeColor = Color(0xFFBDBDBD);
  static const Color graphCenterColor = Color(0xFFFF5722);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        surface: surfaceColor,
        error: errorColor,
      ),

      // App bar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
      ),

      // Text theme optimized for Chinese characters
      textTheme: const TextTheme(
        // Large Chinese characters
        displayLarge: TextStyle(fontSize: 48, fontWeight: FontWeight.w400, color: hanziColor, height: 1.2),
        displayMedium: TextStyle(fontSize: 36, fontWeight: FontWeight.w400, color: hanziColor, height: 1.2),
        displaySmall: TextStyle(fontSize: 28, fontWeight: FontWeight.w400, color: hanziColor, height: 1.2),

        // Headings
        headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: hanziColor),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: hanziColor),
        headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: hanziColor),

        // Body text
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: definitionColor, height: 1.5),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: definitionColor, height: 1.5),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: pinyinColor, height: 1.4),

        // Labels
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: hanziColor),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: pinyinColor),
        labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: pinyinColor),
      ),

      // Card theme
      cardTheme: CardTheme(
        color: surfaceColor,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: const TextStyle(color: pinyinColor),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // Icon theme
      iconTheme: const IconThemeData(color: hanziColor, size: 24),

      // Divider theme
      dividerTheme: const DividerThemeData(color: Color(0xFFE0E0E0), thickness: 1, space: 1),
    );
  }

  // Custom text styles for Chinese characters
  static const TextStyle hanziLarge = TextStyle(
    fontSize: 64,
    fontWeight: FontWeight.w300,
    color: hanziColor,
    height: 1.0,
  );

  static const TextStyle hanziMedium = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w400,
    color: hanziColor,
    height: 1.1,
  );

  static const TextStyle hanziSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    color: hanziColor,
    height: 1.2,
  );

  static const TextStyle pinyinStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: pinyinColor,
    fontStyle: FontStyle.italic,
  );

  static const TextStyle definitionStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: definitionColor,
    height: 1.4,
  );

  static const TextStyle componentStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: componentColor);
}
