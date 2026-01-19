import 'package:flutter/material.dart';
import '../services/finance_api_service.dart';
import '../theme/colors.dart';
import '../utils/responsive.dart';
import 'cost_entry_dialog.dart';

class InvoiceItemsDialog extends StatefulWidget {
  final String invoiceId;
  final VoidCallback onUpdate;

  const InvoiceItemsDialog({
    super.key,
    required this.invoiceId,
    required this.onUpdate,
  });

  @override
  State<InvoiceItemsDialog> createState() => _InvoiceItemsDialogState();
}

class _InvoiceItemsDialogState extends State<InvoiceItemsDialog> {
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
      setState(() => _isLoading = false);
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Responsive.cardRadius),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'عناصر الفاتورة',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '#${widget.invoiceId.split('-').last}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: LaapakColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_items.isEmpty)
              const Center(child: Text('لا توجد عناصر'))
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    final cost =
                        double.tryParse(item['cost_price'].toString()) ?? 0;
                    final hasCost = cost > 0;

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        item['description'] ?? 'منتج',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        hasCost ? 'التكلفة: $cost' : 'لا توجد تكلفة',
                        style: TextStyle(
                          color: hasCost
                              ? LaapakColors.success
                              : LaapakColors.error,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: LaapakColors.primary,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => CostEntryDialog(
                              itemId:
                                  item['id'], // This should be an int from API
                              itemName: item['description'] ?? 'منتج',
                              onSuccess: () {
                                _fetchItems(); // Refresh items to show new cost
                                widget
                                    .onUpdate(); // Refresh parent to show new total profit
                              },
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق'),
            ),
          ],
        ),
      ),
    );
  }
}
