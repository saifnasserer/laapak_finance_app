import 'package:flutter/material.dart';
import 'package:laapak_finance/theme/colors.dart';
import 'package:intl/intl.dart' as intl;

class WeekNavigator extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final VoidCallback onNext;
  final VoidCallback onPrev;
  final bool isLoading;

  const WeekNavigator({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onNext,
    required this.onPrev,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Format: "Jan 14 - Jan 20" (English) or localized
    final dateFormat = intl.DateFormat('d MMM', 'ar');

    final dateRangeText =
        '${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}';

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent, // Changed to transparent
        borderRadius: BorderRadius.circular(50),
        // Removed border and boxShadow
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Previous Button
          _NavButton(icon: Icons.chevron_left, onTap: onPrev),

          // Date Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            constraints: const BoxConstraints(minWidth: 100),
            alignment: Alignment.center,
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    dateRangeText,
                    style: const TextStyle(
                      color: LaapakColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
          ),

          // Next Button
          _NavButton(icon: Icons.chevron_right, onTap: onNext),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: Icon(icon, color: LaapakColors.primary, size: 20),
        ),
      ),
    );
  }
}
