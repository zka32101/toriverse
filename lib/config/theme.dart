import 'package:flutter/material.dart';

/// Toriverse theme configuration with 3-color design system
class ToriverseTheme {
  // Stone colors
  static const Color stoneBlack = Color(0xFF2E2E2E); // 黒: 重厚感
  static const Color stoneWhite = Color(0xFFFFFFFF); // 白: 清涼
  static const Color stoneRed = Color(0xFFE63946);   // 赤: 派手め

  // Semantic colors
  static const Color accentRed = Color(0xFFE63946);
  static const Color boardGreen = Color(0xFF1B5E20);
  static const Color validMoveHighlight = Color(0xFF4CAF50);

  // Spacing constants
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;

  // Minimum tap target size (44pt as per requirements)
  static const double minTapSize = 44.0;

  // Typography sizes
  static const double headingFontSize = 28.0; // Roboto 700
  static const double bodyFontSize = 16.0;   // Roboto 400
  static const double buttonFontSize = 16.0;

  /// Get light theme
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentRed,
        brightness: Brightness.light,
      ),
      typography: Typography.material2021(),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: stoneBlack,
        centerTitle: true,
      ),
      buttonTheme: const ButtonThemeData(
        minWidth: minTapSize,
        height: minTapSize,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(minTapSize, minTapSize),
          padding: const EdgeInsets.symmetric(
            horizontal: spacing16,
            vertical: spacing12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(minTapSize, minTapSize),
          padding: const EdgeInsets.symmetric(
            horizontal: spacing16,
            vertical: spacing12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  /// Get dark theme
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentRed,
        brightness: Brightness.dark,
      ),
      typography: Typography.material2021(),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      buttonTheme: const ButtonThemeData(
        minWidth: minTapSize,
        height: minTapSize,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(minTapSize, minTapSize),
          padding: const EdgeInsets.symmetric(
            horizontal: spacing16,
            vertical: spacing12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(minTapSize, minTapSize),
          padding: const EdgeInsets.symmetric(
            horizontal: spacing16,
            vertical: spacing12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  /// Get color for stone by player index or constant
  static Color getStoneColor(int stoneValue) {
    switch (stoneValue) {
      case 0: // Black
        return stoneBlack;
      case 1: // White
        return stoneWhite;
      case 2: // Red
        return stoneRed;
      default:
        return Colors.transparent;
    }
  }

  /// Get player name (JP)
  static String getPlayerName(int playerIndex) {
    switch (playerIndex) {
      case 0:
        return '黒';
      case 1:
        return '白';
      case 2:
        return '赤';
      default:
        return 'Player $playerIndex';
    }
  }
}
