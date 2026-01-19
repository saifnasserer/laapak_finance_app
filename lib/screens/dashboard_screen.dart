import 'package:flutter/material.dart';
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
      // API integration: In real app, pass dates. Using mock/existing for now as per previous code.
      // We will assume the API returns data relevant to the timeframe or we filter it.
      // For this refactor, we keep the existing mock data generation but structure it for the cache.
      await _apiService.getFinancialSummary();

      if (mounted) {
        final newSummary = {
          'revenue': 15250.0,
          'expenses': 4500.0,
          'net_profit': 10750.0, // Revenue - Expenses
          'margin': 70.5,
        };

        final newTrend = [
          {'label': 'Sat', 'revenue': 2000.0, 'expenses': 500.0},
          {'label': 'Sun', 'revenue': 3500.0, 'expenses': 1200.0},
          {'label': 'Mon', 'revenue': 1000.0, 'expenses': 300.0},
          {'label': 'Tue', 'revenue': 4500.0, 'expenses': 1500.0},
          {'label': 'Wed', 'revenue': 2750.0, 'expenses': 800.0},
          {'label': 'Thu', 'revenue': 1500.0, 'expenses': 200.0},
          {'label': 'Fri', 'revenue': 0.0, 'expenses': 0.0},
        ];

        final newExpenses = {
          'تشغيل': 2000.0,
          'رواتب': 1500.0,
          'نثريات': 1000.0,
        };

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
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
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
            centerTitle: false,
            title: WeekNavigator(
              startDate: _selectedStartDate,
              endDate: _selectedEndDate,
              isLoading: _isLoading,
              onPrev: _previousWeek,
              onNext: _nextWeek,
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.refresh,
                  color: LaapakColors.textSecondary,
                ),
                onPressed: () => _fetchData(forceRefresh: true),
              ),
              const SizedBox(width: 8),
            ],
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
                  label: 'الإيرادات',
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
                        'الإيرادات والمصروفات',
                        style: TextStyle(
                          color: LaapakColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 250,
                        child: TrendChart(
                          labels: _trendData
                              .map((e) => e['label'] as String)
                              .toList(),
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
                        child: ExpenseChart(data: _expenseDistribution),
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
