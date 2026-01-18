import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../services/finance_api_service.dart';
import '../theme/colors.dart';
import '../widgets/responsive.dart';
import '../widgets/cost_entry_dialog.dart';

class ProfitManagementScreen extends StatefulWidget {
  const ProfitManagementScreen({super.key});

  @override
  State<ProfitManagementScreen> createState() => _ProfitManagementScreenState();
}

class _ProfitManagementScreenState extends State<ProfitManagementScreen> {
  final FinanceApiService _apiService = FinanceApiService();
  List<Transaction> _transactions = [];
  bool _isLoading = true;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiService.getFinancialLedger(
        type: 'income',
        startDate: DateFormat('yyyy-MM-dd').format(_startDate),
        endDate: DateFormat('yyyy-MM-dd').format(_endDate),
      );

      final List<dynamic> list = data['transactions'] ?? [];
      setState(() {
        _transactions = list.map((e) => Transaction.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Mock data for demo
          _transactions = [
            Transaction(
              id: 'INV-1001',
              date: DateTime.now(),
              amount: 1500,
              type: 'income',
              category: 'Sales',
              status: 'paid',
              description: 'iPhone 13 Case',
              items: [
                InvoiceItem(
                  id: 1,
                  name: 'iPhone 13 Case',
                  sellPrice: 1500,
                  costPrice: 0,
                ),
              ],
            ),
          ];
        });
      }
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الأرباح'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDateRange,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(Responsive.screenPadding),
              itemCount: _transactions.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: Responsive.itemGap),
              itemBuilder: (context, index) {
                final transaction = _transactions[index];
                // Check if any item has missing cost
                final hasMissingCost =
                    transaction.items?.any(
                      (i) => i.costPrice == null || i.costPrice == 0,
                    ) ??
                    true;

                return Card(
                  elevation: 0,
                  color: hasMissingCost
                      ? LaapakColors.error.withValues(alpha: 0.1)
                      : LaapakColors.primary.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Responsive.cardRadius),
                    side: hasMissingCost
                        ? const BorderSide(color: LaapakColors.error, width: 1)
                        : BorderSide.none,
                  ),
                  child: ExpansionTile(
                    title: Text('فاتورة #${transaction.id}'),
                    subtitle: Text(
                      '${DateFormat('yyyy-MM-dd').format(transaction.date)} - ${transaction.amount} EGP',
                    ),
                    children:
                        transaction.items?.map((item) {
                          return ListTile(
                            title: Text(item.name),
                            trailing: Text(
                              item.costPrice != null && item.costPrice! > 0
                                  ? 'تكلفة: ${item.costPrice}'
                                  : '🔴 أدخل التكلفة',
                            ),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => CostEntryDialog(
                                  itemId: item.id,
                                  itemName: item.name,
                                  onSuccess: _fetchData,
                                ),
                              );
                            },
                          );
                        }).toList() ??
                        [],
                  ),
                );
              },
            ),
    );
  }
}
