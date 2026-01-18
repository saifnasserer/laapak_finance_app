import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:laapak_finance/screens/main_screen.dart';
import 'package:laapak_finance/screens/profit_management_screen.dart';
import 'package:laapak_finance/screens/expenses_screen.dart';
import 'package:laapak_finance/theme/app_theme.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ar', null);
  });

  testWidgets('MainScreen Smoke Test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: const MainScreen()),
    );
    await tester.pumpAndSettle(); // Wait for all animations and futures
    expect(find.text('الإدارة المالية'), findsOneWidget);
    expect(find.text('الرئيسية'), findsOneWidget);
    expect(find.text('الأرباح'), findsOneWidget);
    expect(find.text('المصروفات'), findsOneWidget);
  });

  testWidgets('ProfitManagementScreen Smoke Test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const ProfitManagementScreen(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('إدارة الأرباح والتكاليف'), findsOneWidget);
    expect(find.text('سجل الفواتير'), findsOneWidget);
  });

  testWidgets('ExpensesScreen Smoke Test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: const ExpensesScreen()),
    );
    await tester.pumpAndSettle();
    expect(find.text('المصروفات'), findsOneWidget);
  });
}
