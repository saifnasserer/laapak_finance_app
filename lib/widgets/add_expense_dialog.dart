import 'package:flutter/material.dart';
import '../services/finance_api_service.dart';
import '../widgets/buttons.dart';
import '../widgets/inputs.dart';
import '../utils/responsive.dart';

class AddExpenseDialog extends StatefulWidget {
  final VoidCallback onSuccess;

  const AddExpenseDialog({super.key, required this.onSuccess});

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  final _apiService = FinanceApiService();

  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await _apiService.createExpense(
        name: _nameController.text,
        amount: double.parse(_amountController.text),
        categoryId:
            1, // Defaulting to 1 for demo as categories endpoint not implemented
        date: _selectedDate,
        description: _descController.text,
      );
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
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'إضافة مصروف جديد',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                MinimalTextField(
                  controller: _nameController,
                  hintText: 'اسم المصروف (Replaced by category later)',
                  validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 16),
                MinimalTextField(
                  controller: _amountController,
                  hintText: 'المبلغ',
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 16),
                MinimalTextField(
                  controller: _descController,
                  hintText: 'ملاحظات',
                ),
                const SizedBox(height: 24),
                // Date Picker Button Mockup
                OutlinedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2023),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => _selectedDate = picked);
                  },
                  child: Text(
                    'التاريخ: ${_selectedDate.toIso8601String().split('T')[0]}',
                  ),
                ),
                const SizedBox(height: 24),
                LoadingButton(
                  text: 'إضافة',
                  onPressed: _submit,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
