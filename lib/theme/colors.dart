import 'package:flutter/material.dart';

class LaapakColors {
  // Brand Colors - Laapak Green
  static const Color brandPrimary = Color(0xFF007553);
  static const Color brandPrimaryLight = Color(0xFF00A67A);
  static const Color brandPrimaryDark = Color(0xFF004D35);

  // Neutral System (Dominant)
  static const Color neutral900 = Color(0xFF212529); // Deep Text
  static const Color neutral700 = Color(0xFF495057); // Secondary Text
  static const Color neutral500 = Color(0xFF6C757D); // Muted/Meta
  static const Color neutral200 = Color(0xFFE9ECEF); // Borders/Dividers
  static const Color neutral100 = Color(0xFFF8F9FA); // Backgrounds

  static const Color white = Color(0xFFFFFFFF);

  // Functional Colors
  static const Color success = Color(0xFF198754);
  static const Color warning = Color(0xFFFFC107);
  static const Color danger = Color(0xFFDC3545);

  // UI Variables
  static const Color pageBg = neutral100;
  static const Color cardBg = white;

  // Gradients (Derived from brand)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [brandPrimary, brandPrimaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
