import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/finance_api_service.dart';
import '../theme/colors.dart';
import '../widgets/buttons.dart';
import '../widgets/inputs.dart';

import '../models/transaction.dart';

class AddExpenseDialog extends StatefulWidget {
  final VoidCallback onSuccess;
  final Transaction? expense;

  const AddExpenseDialog({super.key, required this.onSuccess, this.expense});

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _apiService = FinanceApiService();

  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();

  // Category State
  List<Map<String, dynamic>> _categories = [];
  bool _loadingCategories = true;
  int? _selectedCategoryId;

  // Location State
  List<Map<String, dynamic>> _locations = [];
  bool _loadingLocations = true;
  int? _selectedLocationId;

  // Type State
  String _selectedType = 'variable';

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _nameController.text =
          (widget.expense!.nameAr ?? widget.expense!.name) ?? '';
      _amountController.text = widget.expense!.amount.toString();
      _selectedDate = widget.expense!.date;
      _selectedCategoryId = widget.expense!.categoryId;
      _selectedLocationId = widget.expense!.moneyLocationId;
      _selectedType = widget.expense!.expenseType ?? 'variable';
    }
    _fetchData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    await Future.wait([_fetchCategories(), _fetchLocations()]);
  }

  Future<void> _fetchCategories() async {
    try {
      final cats = await _apiService.getExpenseCategories();
      if (mounted) {
        setState(() {
          _categories = cats;
          _loadingCategories = false;
          // Ensure IDs are ints and select default if needed
          if (_categories.isNotEmpty && _selectedCategoryId == null) {
            final firstId = _categories.first['id'];
            _selectedCategoryId = firstId is int
                ? firstId
                : int.tryParse(firstId.toString());
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingCategories = false);
      }
    }
  }

  Future<void> _fetchLocations() async {
    try {
      final locs = await _apiService.getMoneyLocations();
      if (mounted) {
        setState(() {
          _locations = locs;
          _loadingLocations = false;
          if (_locations.isNotEmpty && _selectedLocationId == null) {
            final firstId = _locations.first['id'];
            _selectedLocationId = firstId is int
                ? firstId
                : int.tryParse(firstId.toString());
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingLocations = false);
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('برجاء اختيار التصنيف')));
      return;
    }
    if (_selectedLocationId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('برجاء اختيار خزنة الصرف')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (widget.expense != null) {
        await _apiService.updateExpense(
          id: int.parse(widget.expense!.id),
          name: _nameController.text,
          nameAr: _nameController.text,
          amount: double.parse(_amountController.text),
          categoryId: _selectedCategoryId!,
          moneyLocationId: _selectedLocationId!,
          date: _selectedDate,
          type: _selectedType,
          description: null,
        );
      } else {
        await _apiService.createExpense(
          name: _nameController.text,
          nameAr: _nameController.text,
          amount: double.parse(_amountController.text),
          categoryId: _selectedCategoryId!,
          moneyLocationId: _selectedLocationId!,
          date: DateTime.now(),
          type: _selectedType,
          description: null,
        );
      }
      widget.onSuccess();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.expense != null
                  ? 'فشل تعديل المصروف'
                  : 'فشل إضافة المصروف',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
        decoration: BoxDecoration(
          color: LaapakColors.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 12, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.expense != null
                        ? 'تعديل المصروف'
                        : 'إضافة مصروف جديد',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: LaapakColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: LaapakColors.background,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: LaapakColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('المعلومات الأساسية'),
                      MinimalTextField(
                        controller: _amountController,
                        hintText: 'المبلغ المستحق',
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                      ),
                      const SizedBox(height: 12),
                      MinimalTextField(
                        controller: _nameController,
                        hintText: 'اسم المصروف',
                        validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                      ),
                      const SizedBox(height: 24),

                      _buildSectionTitle('تصنيف المصروف'),
                      _buildDropdown<int>(
                        label: 'التصنيف',
                        loading: _loadingCategories,
                        value: _selectedCategoryId,
                        items: _categories.map((cat) {
                          final id = cat['id'] is int
                              ? cat['id'] as int
                              : int.parse(cat['id'].toString());
                          return DropdownMenuItem<int>(
                            value: id,
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: HexColor.fromHex(
                                      cat['color'] ?? '#666',
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    cat['name_ar'] ?? cat['name'],
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (v) =>
                            setState(() => _selectedCategoryId = v),
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown<int>(
                        label: 'خزنة الصرف',
                        loading: _loadingLocations,
                        value: _selectedLocationId,
                        items: _locations.map((loc) {
                          final id = loc['id'] is int
                              ? loc['id'] as int
                              : int.parse(loc['id'].toString());
                          return DropdownMenuItem<int>(
                            value: id,
                            child: Text(
                              loc['name_ar'] ?? loc['name'],
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                          );
                        }).toList(),
                        onChanged: (v) =>
                            setState(() => _selectedLocationId = v),
                      ),
                      const SizedBox(height: 16),
                      _buildTypeToggle(),
                      const SizedBox(height: 32),

                      LoadingButton(
                        text: widget.expense != null
                            ? 'حفظ التعديلات'
                            : 'إضافة المصروف',
                        onPressed: _submit,
                        isLoading: _isLoading,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: LaapakColors.textSecondary.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required bool loading,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: LinearProgressIndicator(minHeight: 2),
          )
        else
          DropdownButtonFormField<T>(
            value: value,
            isExpanded: true,
            style: const TextStyle(
              fontSize: 14,
              color: LaapakColors.textPrimary,
              fontFamily: 'Cairo', // Assuming Cairo or similar is used
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: LaapakColors.background,
              hintText: label,
              labelText: label,
              labelStyle: const TextStyle(
                fontSize: 12,
                color: LaapakColors.textSecondary,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: LaapakColors.border.withValues(alpha: 0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: LaapakColors.primary,
                  width: 1.5,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            items: items,
            onChanged: onChanged,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: LaapakColors.textSecondary,
            ),
            dropdownColor: LaapakColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
      ],
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: LaapakColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: LaapakColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          _buildTypeOption(
            'متغير',
            'variable',
            Icons.trending_up_rounded,
            LaapakColors.error,
          ),
          const SizedBox(width: 4),
          _buildTypeOption(
            'ثابت',
            'fixed',
            Icons.push_pin_rounded,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeOption(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? LaapakColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? LaapakColors.border : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? color : LaapakColors.textSecondary,
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? LaapakColors.textPrimary
                      : LaapakColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper for Hex Color
extension HexColor on Color {
  static Color fromHex(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }
}
