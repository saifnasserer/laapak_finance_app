import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/finance_api_service.dart';
import '../theme/colors.dart';
import '../utils/responsive.dart';
import '../widgets/buttons.dart';
import '../widgets/inputs.dart';

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
        categoryId: 1, // Defaulting to 1 for demo
        date: _selectedDate,
        description: _descController.text,
      );
      widget.onSuccess();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('فشل إضافة المصروف')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: LaapakColors.surface,
          borderRadius: BorderRadius.circular(Responsive.cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'إضافة مصروف',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: LaapakColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close,
                          color: LaapakColors.textSecondary,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Name Field
                  MinimalTextField(
                    controller: _nameController,
                    hintText: 'اسم المصروف (مثال: كهرباء)',
                    validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                  ),
                  const SizedBox(height: 16),

                  // Amount Field
                  MinimalTextField(
                    controller: _amountController,
                    hintText: 'المبلغ',
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                  ),
                  const SizedBox(height: 16),

                  // Description Field
                  MinimalTextField(
                    controller: _descController,
                    hintText: 'ملاحظات إضافية',
                  ),
                  const SizedBox(height: 20),

                  // Date Picker
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2023),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: LaapakColors.primary,
                                onPrimary: Colors.white,
                                onSurface: LaapakColors.textPrimary,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                    borderRadius: BorderRadius.circular(
                      Responsive.buttonRadius,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: LaapakColors.border),
                        borderRadius: BorderRadius.circular(
                          Responsive.buttonRadius,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 18,
                            color: LaapakColors.textSecondary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat(
                              'd MMM yyyy',
                              'ar',
                            ).format(_selectedDate),
                            style: const TextStyle(
                              color: LaapakColors.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: LaapakColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
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
      ),
    );
  }
}
