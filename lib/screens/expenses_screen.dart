import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../services/finance_api_service.dart';
import '../theme/colors.dart';
import '../widgets/responsive.dart';
import '../widgets/add_expense_dialog.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final FinanceApiService _apiService = FinanceApiService();
  List<Transaction> _expenses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiService.getFinancialLedger(type: 'expense');
      final List<dynamic> list = data['transactions'] ?? [];
      setState(() {
        _expenses = list.map((e) => Transaction.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Mock data
          _expenses = [
            Transaction(
              id: 'EXP-001',
              date: DateTime.now(),
              amount: 500,
              type: 'expense',
              category: 'Rent',
              description: 'Office Rent',
              status: 'verified',
            ),
          ];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المصروفات'),
        backgroundColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: LaapakColors.brandPrimary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AddExpenseDialog(onSuccess: _fetchData),
          );
        },
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(Responsive.screenPadding),
              itemCount: _expenses.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: Responsive.itemGap),
              itemBuilder: (context, index) {
                final expense = _expenses[index];
                return Card(
                  elevation: 0,
                  color: LaapakColors.neutral100, // Light background for item
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Responsive.cardRadius),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.receipt_long,
                        color: LaapakColors.neutral500,
                      ),
                    ),
                    title: Text('${expense.amount} EGP'),
                    subtitle: Text(expense.description ?? expense.category),
                    trailing: Text(DateFormat('MMM dd').format(expense.date)),
                  ),
                );
              },
            ),
    );
  }
}
