import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/colors.dart';
import '../services/finance_api_service.dart';
import '../widgets/week_navigator.dart';
import 'invoice_details_screen.dart';
import 'dashboard_screen.dart';

class ProfitManagementScreen extends StatefulWidget {
  const ProfitManagementScreen({super.key});

  @override
  State<ProfitManagementScreen> createState() => _ProfitManagementScreenState();
}

class _ProfitManagementScreenState extends State<ProfitManagementScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  DateTime _selectedStartDate = DateTime.now();
  DateTime _selectedEndDate = DateTime.now();

  // Filter State
  bool _isReviewMode = false;
  String _searchQuery = '';

  final FinanceApiService _apiService = FinanceApiService();
  final Map<String, List<dynamic>> _invoiceCache = {};
  List<dynamic> _invoices = [];

  @override
  void initState() {
    super.initState();
    _initializeWeek();
    _fetchData();
  }

  void _initializeWeek() {
    final now = DateTime.now();
    _selectedStartDate = now.subtract(Duration(days: now.weekday % 7));
    _selectedEndDate = _selectedStartDate.add(const Duration(days: 6));
  }

  Future<void> _fetchData({bool forceRefresh = false}) async {
    final cacheKey = DateFormat('yyyy-MM-dd', 'en').format(_selectedStartDate);

    // Check cache first
    if (!forceRefresh && _invoiceCache.containsKey(cacheKey)) {
      setState(() {
        _invoices = List.from(_invoiceCache[cacheKey]!);
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });
    try {
      final data = await _apiService.getFinancialLedger(
        startDate: cacheKey,
        endDate: DateFormat('yyyy-MM-dd', 'en').format(_selectedEndDate),
        type: 'income',
        limit: 100, // Fetch enough for the week
      );

      final List<dynamic> transactions = data['transactions'] ?? [];

      if (transactions.isNotEmpty) {
        debugPrint('First Transaction Raw: ${transactions.first}');
      }

      final mappedInvoices = transactions.map((t) {
        // Map API response to UI model
        // API fields: id, amount, date, description, cost (assumed), profit (assumed), client_name (assumed)
        return {
          'id': t['id'],
          'date': DateTime.parse(t['date']),
          'total': (t['amount'] as num).toDouble(),
          // Ensure cost/profit are handled safely if missing
          'total_cost': (t['cost'] ?? 0).toDouble(),
          // 'profit' might need calculation or be present.
          // If missing, profit = total - cost.
          'profit': (t['profit'] ?? ((t['amount'] as num) - (t['cost'] ?? 0)))
              .toDouble(),
          'status': t['status'] ?? 'completed',
          // Try to get client name. If not present, parse from description or use fallback
          'client_name':
              t['client_name'] ??
              (t['description'] as String).split('-').last.trim(),
          'has_missing_costs': t['has_missing_costs'],
          // Keep original object for referencing if needed
          'raw': t,
        };
      }).toList();

      setState(() {
        _isLoading = false;
        _invoices = mappedInvoices;
        // Update cache
        _invoiceCache[cacheKey] = mappedInvoices;
      });
    } catch (e) {
      debugPrint('Error loading profit data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
        // Removed ScaffoldMessenger to avoid spamming user if they are just opening the app
        // The error UI will show instead
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
    if (amount == null) return "0.0";
    final val = amount is num ? amount.toDouble() : 0.0;
    final format = NumberFormat.currency(
      locale: 'ar',
      // symbol: 'ج.m',
      decimalDigits: 0,
    );
    return format.format(val);
  }

  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    // Filter logic
    final filteredInvoices = _invoices.where((inv) {
      if (_isReviewMode && (inv['total_cost'] as num) > 0) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final clientName = (inv['client_name'] as String? ?? '').toLowerCase();
        final id = (inv['id'].toString()).toLowerCase();
        return clientName.contains(q) || id.contains(q);
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: LaapakColors.background,
      body: RefreshIndicator(
        onRefresh: _fetchData,
        color: LaapakColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: true,
              backgroundColor: LaapakColors.surface,
              elevation: 2,
              toolbarHeight: 56, // Standard height
              // Title: Search Field OR WeekNavigator
              title: _isSearching
                  ? TextField(
                      autofocus: true,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      style: const TextStyle(fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'بحث...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintStyle: TextStyle(color: LaapakColors.textSecondary),
                      ),
                    )
                  : FittedBox(
                      fit: BoxFit.scaleDown,
                      child: WeekNavigator(
                        startDate: _selectedStartDate,
                        endDate: _selectedEndDate,
                        isLoading: _isLoading,
                        onPrev: _previousWeek,
                        onNext: _nextWeek,
                      ),
                    ),
              centerTitle: true,
              // Actions: Search Icon/Close, Review Toggle, Nav Shortcut
              actions: [
                if (_isSearching)
                  IconButton(
                    icon: const Icon(Icons.close),
                    color: LaapakColors.textSecondary,
                    onPressed: () {
                      setState(() {
                        _isSearching = false;
                        _searchQuery = '';
                      });
                    },
                  )
                else ...[
                  // Analysis Button (Circular)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: LaapakColors.background,
                      shape: BoxShape.circle,
                      border: Border.all(color: LaapakColors.border, width: 1),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.analytics_outlined,
                        size: 20,
                        color: LaapakColors.textPrimary,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DashboardScreen(),
                          ),
                        );
                      },
                      tooltip: 'التحليل المالي',
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert,
                      color: LaapakColors.textPrimary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (value) {
                      switch (value) {
                        case 'search':
                          setState(() => _isSearching = true);
                          break;
                        case 'review':
                          setState(() => _isReviewMode = !_isReviewMode);
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      // Search Item
                      const PopupMenuItem(
                        value: 'search',
                        child: Row(
                          children: [
                            Icon(
                              Icons.search,
                              size: 20,
                              color: LaapakColors.textSecondary,
                            ),
                            SizedBox(width: 12),
                            Text('بحث'),
                          ],
                        ),
                      ),
                      // Review Mode Item
                      PopupMenuItem(
                        value: 'review',
                        child: Row(
                          children: [
                            Icon(
                              _isReviewMode
                                  ? Icons.check_circle
                                  : Icons.rate_review_outlined,
                              size: 20,
                              color: _isReviewMode
                                  ? LaapakColors.success
                                  : LaapakColors.textSecondary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _isReviewMode ? 'عرض الكل' : 'وضع المراجعة',
                              style: TextStyle(
                                color: _isReviewMode
                                    ? LaapakColors.success
                                    : null,
                                fontWeight: _isReviewMode
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),

            // List
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
                            'عذراً، حدث خطأ أثناء تحميل البيانات',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: LaapakColors.textPrimary,
                            ),
                          ),
                          if (_errorMessage.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                              ),
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
                            onPressed: () => _fetchData(forceRefresh: true),
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
                : filteredInvoices.isEmpty
                ? const SliverFillRemaining(
                    child: Center(child: Text('لا يوجد بيانات')),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final inv = filteredInvoices[index];
                      return _buildInvoiceCard(inv);
                    }, childCount: filteredInvoices.length),
                  ),

            // Bottom Padding
            const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
          ],
        ),
      ),
    );
  }

  bool _isInvoiceIncomplete(Map<String, dynamic> inv) {
    // 1. Prefer local flag if set (from details screen return)
    if (inv.containsKey('has_missing_costs')) {
      return inv['has_missing_costs'] == true;
    }

    // 2. Check for items in the list object (if API returns them)
    final items = inv['InvoiceItems'] ?? inv['invoice_items'];
    if (items != null && items is List && items.isNotEmpty) {
      return items.any((item) {
        // Handle various potential cost field names or types
        final costVal = item['cost_price'] ?? item['cost'];
        final cost = double.tryParse(costVal.toString()) ?? 0;
        return cost == 0;
      });
    }

    // 3. Fallback: If total cost is 0, it's definitely incomplete (or free, but assuming incomplete for profit tracking)
    // This is imperfect for partial costs but best we can do without item details
    return (inv['total_cost'] as num) == 0;
  }

  Widget _buildInvoiceCard(dynamic inv) {
    // Check local flag or fallback to zero-cost check
    final bool hasMissingCost = _isInvoiceIncomplete(inv);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: LaapakColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: hasMissingCost ? LaapakColors.error : LaapakColors.border,
          width: hasMissingCost ? 1.5 : 1.0,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InvoiceDetailsScreen(
                invoiceId: inv['id'].toString(),
                onUpdate:
                    () {}, // No-op, rely on return value to avoid full refresh
              ),
            ),
          );

          if (result != null && result is Map && mounted) {
            setState(() {
              final index = _invoices.indexWhere((i) => i['id'] == inv['id']);
              if (index != -1) {
                // Update local structure
                final updated = Map<String, dynamic>.from(_invoices[index]);
                updated['total_cost'] = result['totalCost'];
                updated['has_missing_costs'] = result['hasMissingCosts'];

                // Recalculate profit
                final total = (updated['total'] as num).toDouble();
                final cost = (updated['total_cost'] as num).toDouble();
                updated['profit'] = total - cost;

                _invoices[index] = updated;

                // Update cache as well
                final cacheKey = DateFormat(
                  'yyyy-MM-dd',
                  'en',
                ).format(_selectedStartDate);
                if (_invoiceCache.containsKey(cacheKey)) {
                  final cachedList = List<dynamic>.from(
                    _invoiceCache[cacheKey]!,
                  );
                  final cachedIndex = cachedList.indexWhere(
                    (i) => i['id'] == inv['id'],
                  );
                  if (cachedIndex != -1) {
                    cachedList[cachedIndex] = updated;
                    _invoiceCache[cacheKey] = cachedList;
                  }
                }
              }
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 1. Icon / Avatar to fill space ("Less Empty")
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: hasMissingCost
                      ? LaapakColors.error.withOpacity(0.1)
                      : LaapakColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: hasMissingCost
                      ? LaapakColors.error
                      : LaapakColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // 2. Main Info (Client + Date)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      inv['client_name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('yyyy-MM-dd').format(inv['date']),
                      style: const TextStyle(
                        color: LaapakColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    if (!hasMissingCost || (inv['total_cost'] as num) > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        'التكلفة: ${_formattedCurrency(inv['total_cost'])}',
                        style: TextStyle(
                          fontSize: 12,
                          color: LaapakColors.textSecondary.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // 3. Profit Amount (Centered vertically)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Center(
                  child: Text(
                    _formattedCurrency(inv['profit']),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: (inv['profit'] as num) > 0
                          ? LaapakColors.success
                          : LaapakColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
