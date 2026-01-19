import 'package:flutter/material.dart';
import '../services/finance_api_service.dart';
import '../theme/colors.dart';
import '../widgets/cost_entry_dialog.dart';
import '../utils/responsive.dart';

class InvoiceDetailsScreen extends StatefulWidget {
  final String invoiceId;
  final VoidCallback onUpdate;

  const InvoiceDetailsScreen({
    super.key,
    required this.invoiceId,
    required this.onUpdate,
  });

  @override
  State<InvoiceDetailsScreen> createState() => _InvoiceDetailsScreenState();
}

class _InvoiceDetailsScreenState extends State<InvoiceDetailsScreen> {
  final _apiService = FinanceApiService();
  bool _isLoading = true;
  List<dynamic> _items = [];

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiService.getInvoiceDetails(widget.invoiceId);
      final invoice = data['invoice'];
      setState(() {
        _items = invoice['InvoiceItems'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('فشل تحميل التفاصيل: $e')));
      }
    }
  }

  bool _hasMissingCosts() {
    return _items.any((item) {
      final cost = double.tryParse(item['cost_price'].toString()) ?? 0;
      return cost == 0;
    });
  }

  double _calculateTotalCost() {
    return _items.fold(0.0, (sum, item) {
      final cost = double.tryParse(item['cost_price'].toString()) ?? 0;
      return sum + cost;
    });
  }

  void _handlePop() {
    final result = {
      'hasMissingCosts': _hasMissingCosts(),
      'totalCost': _calculateTotalCost(),
    };
    // We don't call widget.onUpdate() here because we want to handle it manually in the parent
    // to avoid full refresh if we can, OR we rely on the parent to use the result.
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LaapakColors.background,
      appBar: AppBar(
        backgroundColor: LaapakColors.surface,
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            const Text(
              'تفاصيل الفاتورة',
              style: TextStyle(
                color: LaapakColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '#${widget.invoiceId.split('-').last}',
              style: const TextStyle(
                color: LaapakColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        leading: BackButton(
          color: LaapakColors.textPrimary,
          onPressed: _handlePop,
        ),
      ),
      // Use PopScope to handle system back button
      body: PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (didPop) return;
          _handlePop();
        },
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _items.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 64,
                      color: LaapakColors.textSecondary.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'لا توجد عناصر في هذه الفاتورة',
                      style: TextStyle(color: LaapakColors.textSecondary),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = _items[index];
                  final cost =
                      double.tryParse(item['cost_price'].toString()) ?? 0;
                  final hasCost = cost > 0;

                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => CostEntryDialog(
                          itemId: item['id'],
                          itemName: item['description'] ?? 'منتج',
                          onSuccess: () {
                            _fetchItems();
                          },
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: LaapakColors.surface,
                        borderRadius: BorderRadius.circular(
                          Responsive.cardRadius,
                        ),
                        border: Border.all(color: LaapakColors.borderLight),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: LaapakColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.inventory_2_outlined,
                              color: LaapakColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['description'] ?? 'منتج',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: LaapakColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      hasCost
                                          ? 'التكلفة: $cost'
                                          : 'لم يتم تحديد التكلفة',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: hasCost
                                            ? LaapakColors.textSecondary
                                            : LaapakColors.error,
                                        fontWeight: hasCost
                                            ? FontWeight.normal
                                            : FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Edit icon indicates interactivity, kept for clarity
                          const Icon(
                            Icons.edit_outlined,
                            color: LaapakColors.primary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
