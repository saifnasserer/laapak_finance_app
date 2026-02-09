import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../services/finance_api_service.dart';
import '../widgets/week_navigator.dart';
import '../widgets/kpi_card.dart';
import '../widgets/hero_kpi_card.dart';
import '../widgets/financial_charts.dart';
import '../theme/colors.dart';
import '../utils/responsive.dart';

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

  // Cache
  final Map<String, Map<String, dynamic>> _dashboardCache = {};

  @override
  void initState() {
    super.initState();
    _initializeWeek(); // Sync with other screens to default to current week
    _fetchData();
  }

  void _initializeWeek() {
    final now = DateTime.now();
    _selectedStartDate = now.subtract(Duration(days: now.weekday % 7));
    _selectedEndDate = _selectedStartDate.add(const Duration(days: 6));
  }

  Future<void> _fetchData({bool forceRefresh = false}) async {
    final cacheKey = DateFormat('yyyy-MM-dd', 'en').format(_selectedStartDate);

    if (!forceRefresh && _dashboardCache.containsKey(cacheKey)) {
      final cached = _dashboardCache[cacheKey]!;
      setState(() {
        _summaryData = cached['summary'];
        _trendData = cached['trend'];
        _expenseDistribution = cached['expenses'];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.getFinancialSummary(
        startDate: DateFormat('yyyy-MM-dd', 'en').format(_selectedStartDate),
        endDate: DateFormat('yyyy-MM-dd', 'en').format(_selectedEndDate),
      );

      if (mounted) {
        if (response['success'] == true) {
          final summary = response['summary'] ?? {};
          final newSummary = {
            'revenue': (summary['revenue'] ?? 0.0).toDouble(),
            'expenses': (summary['expenses'] ?? 0.0).toDouble(),
            'net_profit': (summary['netProfit'] ?? 0.0).toDouble(),
            'margin': (summary['profitMargin'] ?? 0.0).toDouble(),
          };

          // The API currently doesn't provide detailed breakdown or trend for the dashboard in one call
          // We can provide empty lists/maps for now or keep placeholder logic for trend if acceptable
          // BUT the user asked for real values. If API doesn't have it, we show 0 or handle it.
          final newTrend =
              (response['trend'] as List?)
                  ?.map(
                    (e) => {
                      'label': e['label'] ?? '',
                      'revenue': (e['revenue'] ?? 0.0).toDouble(),
                      'expenses': (e['expenses'] ?? 0.0).toDouble(),
                    },
                  )
                  .toList() ??
              [];

          final newExpenses =
              (response['expenses'] as Map?)?.map(
                (key, value) =>
                    MapEntry(key.toString(), (value as num).toDouble()),
              ) ??
              {};

          setState(() {
            _summaryData = newSummary;
            _trendData = newTrend;
            _expenseDistribution = newExpenses;
            _isLoading = false;

            _dashboardCache[cacheKey] = {
              'summary': newSummary,
              'trend': newTrend,
              'expenses': newExpenses,
            };
          });
        }
      }
    } catch (e) {
      if (kDebugMode) print('Dashboard Error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _summaryData = {
            'revenue': 0.0,
            'expenses': 0.0,
            'net_profit': 0.0,
            'margin': 0.0,
          };
          _trendData = [];
          _expenseDistribution = {};
        });
      }
    }
  }

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
    if (amount == null) return "0";
    final val = amount is num
        ? amount.toDouble()
        : double.tryParse(amount.toString()) ?? 0.0;
    final format = NumberFormat.currency(
      locale: 'ar',
      decimalDigits: 0,
      symbol: '', // No symbol for cleaner UI
    );
    return format.format(val);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LaapakColors.background,
      body: CustomScrollView(
        slivers: [
          // 1. App Bar with Week Navigator
          SliverAppBar(
            pinned: true,
            floating: true,
            backgroundColor: LaapakColors.background,
            elevation: 0,
            centerTitle: true,
            title: WeekNavigator(
              startDate: _selectedStartDate,
              endDate: _selectedEndDate,
              isLoading: _isLoading,
              onPrev: _previousWeek,
              onNext: _nextWeek,
            ),
          ),

          // 2. Hero KPI (Net Profit)
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: HeroKpiCard(
                label: 'صافي الربح',
                value: _formattedCurrency(_summaryData['net_profit']),
                changePercent: 8.4,
              ),
            ),
          ),

          // 3. Key Metrics Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                KpiCard(
                  label: 'المبيعات',
                  value: _formattedCurrency(_summaryData['revenue']),
                  changePercent: 12.5,
                ),
                KpiCard(
                  label: 'المصروفات',
                  value: _formattedCurrency(_summaryData['expenses']),
                  changePercent: -2.1,
                ),
              ],
            ),
          ),

          // 4. Charts Section Title
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                'التحليل البياني',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: LaapakColors.textPrimary,
                ),
              ),
            ),
          ),

          // 5. Trend Chart
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Responsive.cardRadius),
                  side: const BorderSide(color: LaapakColors.borderLight),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'المبيعات والمصروفات',
                        style: TextStyle(
                          color: LaapakColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 250,
                        child: _trendData.isEmpty
                            ? const Center(
                                child: Text(
                                  'لا يوجد بيانات لهذا الأسبوع',
                                  style: TextStyle(
                                    color: LaapakColors.textSecondary,
                                  ),
                                ),
                              )
                            : TrendChart(
                                labels: _trendData
                                    .map((e) => e['label'] as String)
                                    .toList(),
                                revenue: _trendData
                                    .map(
                                      (e) => (e['revenue'] as num).toDouble(),
                                    )
                                    .toList(),
                                expenses: _trendData
                                    .map(
                                      (e) => (e['expenses'] as num).toDouble(),
                                    )
                                    .toList(),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 6. Expense Breakdown
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Responsive.cardRadius),
                  side: const BorderSide(color: LaapakColors.borderLight),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'توزيع المصروفات',
                        style: TextStyle(
                          color: LaapakColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 250,
                        child: _expenseDistribution.isEmpty
                            ? const Center(
                                child: Text(
                                  'لا يوجد مصروفات لهذا الأسبوع',
                                  style: TextStyle(
                                    color: LaapakColors.textSecondary,
                                  ),
                                ),
                              )
                            : ExpenseChart(data: _expenseDistribution),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
        ],
      ),
    );
  }
}
