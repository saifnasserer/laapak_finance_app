import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const LaapakFinanceApp());
}

class LaapakFinanceApp extends StatelessWidget {
  const LaapakFinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laapak Finance',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Supporting RTL for Arabic as per design implication (Arabic fonts/text)
      builder: (context, child) {
        return Directionality(textDirection: TextDirection.rtl, child: child!);
      },
      home: const DashboardScreen(),
    );
  }
}
