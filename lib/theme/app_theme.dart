import 'package:flutter/material.dart';

/// Palette taken from the app's dark design.
abstract final class AppColors {
  static const background = Color(0xFF0D1117);
  static const surface = Color(0xFF161B26);
  static const surfaceAlt = Color(0xFF1B2130);
  static const border = Color(0xFF262D3D);
  static const accent = Color(0xFF5B4BF5);
  static const accentSoft = Color(0xFF3B2FA8);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF9AA3B8);
  static const textMuted = Color(0xFF6B7488);
  static const dice = Color(0xFFF5C563);
}

abstract final class AppRadius {
  static const card = 18.0;
  static const field = 12.0;
  static const button = 16.0;
}

ThemeData buildAppTheme() {
  final base = ThemeData.dark(useMaterial3: true);

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.accent,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    ),
    splashFactory: InkSparkle.splashFactory,
  );
}
