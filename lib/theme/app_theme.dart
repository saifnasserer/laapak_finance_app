import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: LaapakColors.background,
      colorScheme: ColorScheme.light(
        primary: LaapakColors.primary,
        secondary: LaapakColors.primaryDark,
        surface: LaapakColors.background,
        error: LaapakColors.error,
        onPrimary: Colors.white,
        onSurface: LaapakColors.textPrimary,
      ),
      fontFamily: LaapakTypography.fontFamily,
      textTheme: TextTheme(
        headlineMedium: LaapakTypography.headlineMedium,
        titleMedium: LaapakTypography.titleMedium,
        bodyLarge: LaapakTypography.bodyLarge,
        bodyMedium: LaapakTypography.bodyMedium,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: LaapakTypography.button,
          backgroundColor: LaapakColors.primary,
          // Note: Actual gradient buttons use container decoration,
          // but this sets a default for standard buttons.
        ),
      ),
    );
  }
}
