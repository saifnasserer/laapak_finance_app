import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';
import '../widgets/responsive.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: LaapakColors.pageBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: LaapakColors.brandPrimary,
        primary: LaapakColors.brandPrimary,
        secondary: LaapakColors.brandPrimaryLight,
        surface: LaapakColors.cardBg,
        error: LaapakColors.danger,
      ),
      cardTheme: CardThemeData(
        color: LaapakColors.cardBg,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Responsive.cardRadius),
          side: const BorderSide(color: LaapakColors.neutral200, width: 1),
        ),
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
          backgroundColor: LaapakColors.brandPrimary,
          // Note: Actual gradient buttons use container decoration,
          // but this sets a default for standard buttons.
        ),
      ),
    );
  }
}
