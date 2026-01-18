import 'package:flutter/material.dart';
import '../services/finance_api_service.dart';

import '../widgets/buttons.dart';
import '../widgets/inputs.dart';
import '../widgets/responsive.dart';

class CostEntryDialog extends StatefulWidget {
  final int itemId;
  final String itemName;
  final VoidCallback onSuccess;

  const CostEntryDialog({
    super.key,
    required this.itemId,
    required this.itemName,
    required this.onSuccess,
  });

  @override
  State<CostEntryDialog> createState() => _CostEntryDialogState();
}

class _CostEntryDialogState extends State<CostEntryDialog> {
  final _costController = TextEditingController();
  final _apiService = FinanceApiService();
  bool _isLoading = false;

  Future<void> _submit() async {
    final cost = double.tryParse(_costController.text);
    if (cost == null) return;

    setState(() => _isLoading = true);
    try {
      await _apiService.updateInvoiceItemCost(widget.itemId, cost);
      widget.onSuccess();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Responsive.cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'تحديث سعر التكلفة',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'المنتج: ${widget.itemName}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            MinimalTextField(
              controller: _costController,
              hintText: 'سعر التكلفة',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            LoadingButton(
              text: 'حفظ',
              onPressed: _submit,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
