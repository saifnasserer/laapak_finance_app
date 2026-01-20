import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../services/finance_api_service.dart';
import '../theme/colors.dart';
import '../widgets/add_expense_dialog.dart';
import '../widgets/week_navigator.dart';
import 'profit_management_screen.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final FinanceApiService _apiService = FinanceApiService();
  List<Transaction> _expenses = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  // Date Filtering
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _initializeWeek();
    _fetchData();
  }

  void _initializeWeek() {
    final now = DateTime.now();
    _startDate = now.subtract(Duration(days: now.weekday % 7));
    _endDate = _startDate.add(const Duration(days: 6));
  }

  void _previousWeek() {
    setState(() {
      _startDate = _startDate.subtract(const Duration(days: 7));
      _endDate = _endDate.subtract(const Duration(days: 7));
    });
    _fetchData();
  }

  void _nextWeek() {
    setState(() {
      _startDate = _startDate.add(const Duration(days: 7));
      _endDate = _endDate.add(const Duration(days: 7));
    });
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });
    try {
      final data = await _apiService.getFinancialLedger(
        type: 'expense',
        startDate: DateFormat('yyyy-MM-dd').format(_startDate),
        endDate: DateFormat('yyyy-MM-dd').format(_endDate),
      );
      final List<dynamic> list = data['transactions'] ?? [];
      setState(() {
        _expenses = list.map((e) => Transaction.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
          _expenses = []; // Clear mock data/previous data if any
        });
      }
    }
  }

  double get _totalExpenses =>
      _expenses.fold(0, (sum, item) => sum + item.amount);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      backgroundColor: LaapakColors.background,
      body: CustomScrollView(
        slivers: [
          // 1. Header with Summary
          SliverAppBar(
            expandedHeight: 140, // Reduced height
            floating: false,
            pinned: true,
            centerTitle: true,
            backgroundColor: LaapakColors.background,
            foregroundColor: LaapakColors.textPrimary,
            title: WeekNavigator(
              startDate: _startDate,
              endDate: _endDate,
              onPrev: _previousWeek,
              onNext: _nextWeek,
              isLoading: _isLoading,
            ),
            actions: [
              Container(
                width: 36,
                height: 36,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: LaapakColors.border),
                ),
                child: IconButton(
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.attach_money),
                  tooltip: 'الأرباح',
                  color: LaapakColors.success,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfitManagementScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: LaapakColors.background,
                alignment: Alignment.bottomCenter,
                padding: const EdgeInsets.only(bottom: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Text(
                      'إجمالي المصروفات:',
                      style: TextStyle(
                        color: LaapakColors.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      NumberFormat.currency(
                        locale: 'ar',
                        decimalDigits: 0,
                        symbol: '',
                      ).format(_totalExpenses),
                      style: const TextStyle(
                        color: LaapakColors.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Expense List
          _isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              : _hasError
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: LaapakColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'عذراً، حدث خطأ أثناء تحميل المصروفات',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: LaapakColors.textPrimary,
                          ),
                        ),
                        if (_errorMessage.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              _errorMessage,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                color: LaapakColors.textSecondary,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _fetchData,
                          icon: const Icon(Icons.refresh),
                          label: const Text('إعادة المحاولة'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: LaapakColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : _expenses.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: LaapakColors.textSecondary.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد مصروفات في هذه الفترة',
                          style: const TextStyle(
                            color: LaapakColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final expense = _expenses[index];
                    return _buildExpenseCard(expense);
                  }, childCount: _expenses.length),
                ),

          // Bottom Padding for FAB
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AddExpenseDialog(onSuccess: _fetchData),
          );
        },
        backgroundColor: LaapakColors.primary,
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildExpenseCard(Transaction expense) {
    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: LaapakColors.error,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        // Implement delete API call here
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: LaapakColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: LaapakColors.error.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.trending_down,
              color: LaapakColors.error,
              size: 24,
            ),
          ),
          title: Text(
            expense.category,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (expense.description != null &&
                  expense.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    expense.description!,
                    style: const TextStyle(
                      color: LaapakColors.textSecondary,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 12,
                    color: LaapakColors.textSecondary.withOpacity(0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('d MMM, yyyy', 'ar').format(expense.date),
                    style: TextStyle(
                      color: LaapakColors.textSecondary.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: Text(
            NumberFormat.currency(
              locale: 'ar',
              decimalDigits: 0,
              symbol: '',
            ).format(expense.amount),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: LaapakColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
