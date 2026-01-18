import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/colors.dart';
import '../services/finance_api_service.dart';
import '../widgets/week_navigator.dart';
import '../widgets/kpi_card.dart';
import '../widgets/financial_charts.dart';
import 'profit_management_screen.dart';
import 'expenses_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FinanceApiService _apiService = FinanceApiService();

  bool _isLoading = true;
  DateTime _selectedStartDate = DateTime.now();
  DateTime _selectedEndDate = DateTime.now();

  // Data State
  Map<String, dynamic> _summaryData = {};
  Map<String, double> _expenseDistribution = {};
  List<dynamic> _trendData = [];

  @override
  void initState() {
    super.initState();
    _initializeDateRange();
    _fetchData();
  }

  void _initializeDateRange() {
    final now = DateTime.now();
    // Default to current month start/end for the dashboard view
    _selectedStartDate = DateTime(now.year, now.month, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    _selectedEndDate = nextMonth.subtract(const Duration(days: 1));
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);

    try {
      // In a real scenario, we would pass dates to the API
      // final data = await _apiService.getFinancialSummary(start: _selectedStartDate, end: _selectedEndDate);
      // For now, using the existing fetch or mock
      await _apiService.getFinancialSummary();

      if (mounted) {
        setState(() {
          _summaryData = {
            'revenue': 15250.0, // Mock or from data
            'expenses': 4500.0,
            'net_profit': 10750.0,
            'margin': 70.5,
          };

          // Mocking Chart Data until API update
          _trendData = [
            {'label': 'P1', 'revenue': 4000.0, 'expenses': 1000.0},
            {'label': 'P2', 'revenue': 3500.0, 'expenses': 1200.0},
            {'label': 'P3', 'revenue': 5000.0, 'expenses': 1500.0},
            {'label': 'P4', 'revenue': 2750.0, 'expenses': 800.0},
          ];

          _expenseDistribution = {
            'Operational': 2000.0,
            'Salaries': 1500.0,
            'Other': 1000.0,
          };

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Fallback mocks
          _summaryData = {
            'revenue': 0.0,
            'expenses': 0.0,
            'net_profit': 0.0,
            'margin': 0.0,
          };
        });
      }
    }
  }

  void _previousWeek() {
    setState(() {
      // Shifting by months for dashboard usually, or weeks if strictly weekly
      // Based on WeekNavigator, let's do weeks for consistency
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
    if (amount == null) return "0 EGP";
    final val = amount is num
        ? amount.toDouble()
        : double.tryParse(amount.toString()) ?? 0.0;
    final format = NumberFormat.currency(
      locale: 'ar',
      symbol: 'EGP',
      decimalDigits: 0,
    );
    return format.format(val);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإدارة المالية'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Week Navigator
                  Center(
                    child: WeekNavigator(
                      startDate: _selectedStartDate,
                      endDate: _selectedEndDate,
                      isLoading: _isLoading,
                      onPrev: _previousWeek,
                      onNext: _nextWeek,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // KPI Grid
                  _buildKpiGrid(),
                  const SizedBox(height: 32),

                  // Charts Row
                  _buildChartsSection(),
                  const SizedBox(height: 32),

                  // Quick Actions
                  const Text(
                    'إجراءات سريعة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: LaapakColors.neutral900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildActionCard(
                        title: 'إدارة الأرباح',
                        icon: Icons.monetization_on_outlined,
                        color: LaapakColors.brandPrimary,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfitManagementScreen(),
                          ),
                        ),
                      ),
                      _buildActionCard(
                        title: 'المصروفات',
                        icon: Icons.receipt_long_outlined,
                        color: LaapakColors.danger,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ExpensesScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildKpiGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        // Logic: Desktop (>900) 4 columns. Tablet (>600) 2 columns. Mobile 1 column.
        int crossAxisCount = width > 900 ? 4 : (width > 600 ? 2 : 1);
        double spacing = 16.0;
        double itemWidth =
            (width - ((crossAxisCount - 1) * spacing)) / crossAxisCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(
              width: itemWidth,
              child: KpiCard(
                label: 'إجمالي الإيرادات',
                value: _formattedCurrency(_summaryData['revenue']),
                changePercent: 12.5,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: KpiCard(
                label: 'إجمالي المصروفات',
                value: _formattedCurrency(_summaryData['expenses']),
                changePercent: -2.1,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: KpiCard(
                label: 'صافي الربح',
                value: _formattedCurrency(_summaryData['net_profit']),
                changePercent: 8.4,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: KpiCard(
                label: 'هامش الربح',
                value: '${_summaryData['margin']}%',
                isCurrency: false,
                changePercent: 1.2,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChartsSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;

        if (isMobile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTrendCard(),
              const SizedBox(height: 24),
              _buildExpenseCard(),
            ],
          );
        } else {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildTrendCard()),
              const SizedBox(width: 24),
              Expanded(flex: 1, child: _buildExpenseCard()),
            ],
          );
        }
      },
    );
  }

  Widget _buildTrendCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'تطور الأداء المالي',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: TrendChart(
                labels: _trendData.map((e) => e['label'] as String).toList(),
                revenue: _trendData
                    .map((e) => (e['revenue'] as num).toDouble())
                    .toList(),
                expenses: _trendData
                    .map((e) => (e['expenses'] as num).toDouble())
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'توزيع المصروفات',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: ExpenseChart(data: _expenseDistribution),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(24),
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
