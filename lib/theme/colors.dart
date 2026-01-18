import 'package:flutter/material.dart';

class LaapakColors {
  static const Color primary = Color(0xFF00C853);
  static const Color primaryDark = Color(0xFF00E676); // Using as gradient end
  static const Color background = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color textPrimary = Color(0xFF2C2C2C);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color error = Color(0xFFD32F2F);

  static const LinearGradient laapakGreenGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
