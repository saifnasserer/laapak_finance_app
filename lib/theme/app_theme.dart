import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';
import '../utils/responsive.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: LaapakColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: LaapakColors.primary,
        primary: LaapakColors.primary,
        secondary: LaapakColors.secondary,
        surface: LaapakColors.surface,
        error: LaapakColors.error,
        background: LaapakColors.background,
      ),
      cardTheme: CardThemeData(
        color: LaapakColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Responsive.cardRadius),
          side: const BorderSide(color: LaapakColors.border, width: 1),
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
          backgroundColor: LaapakColors.primary,
          foregroundColor: LaapakColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Responsive.buttonRadius),
          ),
          padding: Responsive.buttonPadding,
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LaapakColors.surfaceVariant,
        contentPadding: Responsive.inputPaddingInsets,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Responsive.inputRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Responsive.inputRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Responsive.inputRadius),
          borderSide: const BorderSide(color: LaapakColors.primary, width: 2),
        ),
        hintStyle: const TextStyle(color: LaapakColors.textSecondary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: LaapakColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: LaapakColors.textPrimary),
        titleTextStyle: TextStyle(
          color: LaapakColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: LaapakTypography.fontFamily,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: LaapakColors.surface,
        selectedItemColor: LaapakColors.primary,
        unselectedItemColor: LaapakColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
