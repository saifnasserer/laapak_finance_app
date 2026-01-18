import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/colors.dart';
import '../widgets/week_navigator.dart';

import '../widgets/cost_entry_dialog.dart';

class ProfitManagementScreen extends StatefulWidget {
  const ProfitManagementScreen({super.key});

  @override
  State<ProfitManagementScreen> createState() => _ProfitManagementScreenState();
}

class _ProfitManagementScreenState extends State<ProfitManagementScreen> {
  bool _isLoading = true;
  DateTime _selectedStartDate = DateTime.now();
  DateTime _selectedEndDate = DateTime.now();

  // Filter State
  bool _isReviewMode = false;
  String _searchQuery = '';

  // Data
  List<dynamic> _invoices = [];
  Map<String, double> _weekSummary = {'revenue': 0, 'cost': 0, 'profit': 0};

  @override
  void initState() {
    super.initState();
    _initializeWeek();
    _fetchData();
  }

  void _initializeWeek() {
    final now = DateTime.now();
    // Start of week (Sunday as per region usually, or Saturday. Let's assume Saturday/Sunday logic from reference)
    // Reference script: `start.setDate(today.getDate() - today.getDay());` which implies Sunday start if getDay() is standard API.
    // Let's stick to simple "Start of week" logic.
    _selectedStartDate = now.subtract(Duration(days: now.weekday % 7));
    _selectedEndDate = _selectedStartDate.add(const Duration(days: 6));
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      // In real implementation:
      // final data = await _apiService.getProfitData(start: _selectedStartDate, end: _selectedEndDate);
      // For now, mock or generic fetch
      // final data = await _apiService
      //     .getFinancialSummary(); // Just to checking connection or similar

      setState(() {
        _isLoading = false;
        // Mock Invoices
        _invoices = [
          {
            'id': 'INV-1023',
            'date': DateTime.now().subtract(const Duration(days: 1)),
            'items_count': 3,
            'total': 5000.0,
            'total_cost': 3500.0,
            'profit': 1500.0,
            'status': 'paid',
            'client_name': 'Ahmed Ali',
          },
          {
            'id': 'INV-1024',
            'date': DateTime.now(),
            'items_count': 5,
            'total': 12000.0,
            'total_cost': 0.0, // Missing Cost
            'profit': 12000.0,
            'status': 'pending',
            'client_name': 'Global Tech Co',
          },
          {
            'id': 'INV-1025',
            'date': DateTime.now().subtract(const Duration(days: 2)),
            'items_count': 2,
            'total': 2200.0,
            'total_cost': 1800.0,
            'profit': 400.0,
            'status': 'completed',
            'client_name': 'Sara Hassan',
          },
        ];

        _calculateSummary();
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _calculateSummary() {
    double revenue = 0;
    double cost = 0;
    for (var inv in _invoices) {
      revenue += (inv['total'] as num).toDouble();
      cost += (inv['total_cost'] as num).toDouble();
    }
    _weekSummary = {'revenue': revenue, 'cost': cost, 'profit': revenue - cost};
  }

  // .. Week Navigation Logic matches Dashboard ..
  void _previousWeek() {
    setState(() {
      _selectedStartDate = _selectedStartDate.subtract(const Duration(days: 7));
      _selectedEndDate = _selectedEndDate.subtract(const Duration(days: 7));
    });
    _fetchData();
  }

  void _nextWeek() {
    setState(() {
      _selectedStartDate = _selectedStartDate.add(const Duration(days: 7));
      _selectedEndDate = _selectedEndDate.add(const Duration(days: 7));
    });
    _fetchData();
  }

  String _formattedCurrency(dynamic amount) {
    if (amount == null) return "0.0";
    final val = amount is num ? amount.toDouble() : 0.0;
    final format = NumberFormat.currency(
      locale: 'ar',
      symbol: 'ج.م',
      decimalDigits: 0,
    );
    return format.format(val);
  }

  @override
  Widget build(BuildContext context) {
    final filteredInvoices = _invoices.where((inv) {
      final matchSearch = inv['client_name'].toString().toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      if (_isReviewMode) {
        return matchSearch && ((inv['total_cost'] as num) == 0);
      }
      return matchSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الأرباح والتكاليف'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Week Nav
            Center(
              child: WeekNavigator(
                startDate: _selectedStartDate,
                endDate: _selectedEndDate,
                isLoading: _isLoading,
                onPrev: _previousWeek,
                onNext: _nextWeek,
              ),
            ),
            const SizedBox(height: 24),

            // Summary Cards (Row of 3)
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final isMobile = width < 800;
                // On mobile stack, on desktop row
                return Flex(
                  direction: isMobile ? Axis.vertical : Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSummaryCard(
                      'إيرادات الأسبوع',
                      _weekSummary['revenue']!,
                      LaapakColors.neutral900,
                      isMobile,
                    ),
                    if (isMobile) const SizedBox(height: 12),
                    _buildSummaryCard(
                      'التكاليف (الأسبوع)',
                      _weekSummary['cost']!,
                      LaapakColors.danger,
                      isMobile,
                    ),
                    if (isMobile) const SizedBox(height: 12),
                    _buildSummaryCard(
                      'صافي الربح',
                      _weekSummary['profit']!,
                      LaapakColors.success,
                      isMobile,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),

            // Controls & Table Container
            Container(
              decoration: BoxDecoration(
                color: LaapakColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: LaapakColors.neutral200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header: Controls
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.spaceBetween,
                      children: [
                        const Text(
                          'سجل الفواتير',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        // Controls Right
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Review Toggle
                            Switch(
                              value: _isReviewMode,
                              activeColor: LaapakColors.warning,
                              onChanged: (val) =>
                                  setState(() => _isReviewMode = val),
                            ),
                            Text(
                              'وضع المراجعة',
                              style: TextStyle(
                                color: _isReviewMode
                                    ? LaapakColors.warning
                                    : LaapakColors.neutral500,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Search (Simplified as Icon for mobile, expanded for desktop could be better but let's keep it simple)
                            SizedBox(
                              width: 200,
                              height: 40,
                              child: TextField(
                                onChanged: (val) =>
                                    setState(() => _searchQuery = val),
                                decoration: InputDecoration(
                                  hintText: 'بحث باسم العميل...',
                                  prefixIcon: const Icon(
                                    Icons.search,
                                    size: 20,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 0,
                                    horizontal: 16,
                                  ),
                                  filled: true,
                                  fillColor: LaapakColors.neutral100,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: LaapakColors.neutral200),

                  // Table
                  _isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : filteredInvoices.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(child: Text('لا يوجد بيانات')),
                        )
                      : ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: filteredInvoices.length,
                          separatorBuilder: (_, __) => const Divider(
                            height: 1,
                            color: LaapakColors.neutral200,
                          ),
                          itemBuilder: (context, index) {
                            final inv = filteredInvoices[index];
                            final hasMissingCost =
                                (inv['total_cost'] as num) == 0;

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              tileColor: (_isReviewMode && hasMissingCost)
                                  ? LaapakColors.warning.withValues(alpha: 0.1)
                                  : null,
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: LaapakColors.neutral100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.receipt,
                                  color: LaapakColors.neutral500,
                                ),
                              ),
                              title: Text(
                                '${inv['client_name']} (#${inv['id'].toString().split('-').last})',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                DateFormat('yyyy-MM-dd').format(inv['date']),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        _formattedCurrency(inv['total']),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: LaapakColors.brandPrimary,
                                        ),
                                      ),
                                      Text(
                                        hasMissingCost
                                            ? 'تكلفة مفقودة!'
                                            : _formattedCurrency(
                                                inv['total_cost'],
                                              ),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: hasMissingCost
                                              ? LaapakColors.danger
                                              : LaapakColors.neutral500,
                                          fontWeight: hasMissingCost
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 16),
                                  if (hasMissingCost)
                                    OutlinedButton(
                                      onPressed: () {
                                        // Show Cost Entry Dialog (Mocked action - normally would show items list first)
                                        showDialog(
                                          context: context,
                                          builder: (_) => CostEntryDialog(
                                            itemId: 0, // Mock ID
                                            itemName: "عنصر فاتورة غير محدد",
                                            onSuccess: () {
                                              _fetchData();
                                              if (mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'تم تحديث التكلفة (محاكاة)',
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: LaapakColors.danger,
                                        side: const BorderSide(
                                          color: LaapakColors.danger,
                                        ),
                                      ),
                                      child: const Text('تعديل'),
                                    )
                                  else
                                    const Icon(
                                      Icons.chevron_right,
                                      color: LaapakColors.neutral500,
                                    ),
                                ],
                              ),
                              onTap: () {
                                // View Filters Details
                              },
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String label,
    double value,
    Color color,
    bool isMobile,
  ) {
    return Container(
      width: isMobile ? double.infinity : null,
      constraints: isMobile ? null : const BoxConstraints(minWidth: 250),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: LaapakColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LaapakColors.neutral200),
        // No shadow to match clean look or subtle
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04), // --card-shadow
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: LaapakColors.neutral500)),
          const SizedBox(height: 8),
          Text(
            _formattedCurrency(value),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
