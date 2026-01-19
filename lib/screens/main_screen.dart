import 'package:flutter/material.dart';
import 'expenses_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // The MainScreen now acts as a wrapper or simply returns the Home (ProfitManagement)
    // We can also just use ProfitManagementScreen directly in main.dart routes, but keeping MainScreen is safer for existing routing.
    return const ExpensesScreen();
  }
}
