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
  static const double displayFontSize = 40.0; // リザルト画面の逆転演出用大見出し
  static const double headingFontSize = 28.0; // Roboto 700
  static const double bodyFontSize = 16.0;   // Roboto 400
  static const double buttonFontSize = 16.0;
  static const double captionFontSize = 12.0;
  static const double numericFontSize = 20.0; // 石数カウンター等の等幅数字表示用

  // ===== Semantic result colors (順位・石差表示用) =====
  static const Color winningColor = Color(0xFF4CAF50);
  static const Color losingColor = Color(0xFF9E9E9E);
  static const Color neutralColor = Color(0xFFFFC107);

  /// 対立関係インジケーター用（GAME_DESIGN_UI_REFORM.md §2.2）
  static const Color rivalryWarning = Color(0xFFFF7043);

  // ===== Motion tokens (同時公開演出を中心としたモーション言語) =====
  /// 提出締切が近づく際の緊張演出（脈動アニメーション周期）
  static const Duration revealAnticipation = Duration(milliseconds: 900);

  /// くじ引き演出（処理順抽選）の再生時間
  static const Duration lotteryDuration = Duration(milliseconds: 500);

  /// 反転アニメーションの1手あたりの再生間隔
  static const Duration flipStagger = Duration(milliseconds: 800);

  /// 弱者ボーナス発動時の強調パルス
  static const Duration bonusPulse = Duration(milliseconds: 600);

  // ===== Elevation (カード階層の統一) =====
  static const double elevationCard = 1.0;
  static const double elevationRaised = 4.0;
  static const double elevationOverlay = 8.0;

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

  /// 順位に応じたセマンティックカラーを返す（1位=winning, 最下位=losing, それ以外=neutral）
  ///
  /// 3人対戦のため rank は 1〜3 を想定。
  static Color getRankColor(int rank, int totalPlayers) {
    if (rank <= 1) return winningColor;
    if (rank >= totalPlayers) return losingColor;
    return neutralColor;
  }
}
