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
    // Using en_US for now as base, can be switched to ar based on context
    // The reference uses "Day Month - Day Month"
    final dateFormat = intl.DateFormat('d MMM', 'ar');

    final dateRangeText =
        '${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}';

    return Container(
      decoration: BoxDecoration(
        color: LaapakColors.white,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: LaapakColors.neutral200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04), // --card-shadow
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Previous Button
          _NavButton(
            icon: Icons
                .chevron_right, // RTL: Right means previous in time (older) usually, but logic depends on layout.
            // In layout LTR: Left is prev. RTL: Right is prev.
            // Reference HTML: prevWeekBtn has chevron-right (in RTL context).
            onTap: onPrev,
          ),

          // Date Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            constraints: const BoxConstraints(minWidth: 150),
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
                      color: LaapakColors.neutral900,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
          ),

          // Next Button
          _NavButton(
            icon: Icons.chevron_left, // RTL: Left means next (newer).
            onTap: onNext,
          ),
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
          width: 40,
          height: 40,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: Icon(icon, color: LaapakColors.brandPrimary, size: 20),
        ),
      ),
    );
  }
}
