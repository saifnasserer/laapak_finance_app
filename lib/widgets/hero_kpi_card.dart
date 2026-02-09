import 'package:flutter/material.dart';
import 'package:laapak_finance/theme/colors.dart';
import '../utils/responsive.dart';

class HeroKpiCard extends StatelessWidget {
  final String label;
  final String value;
  final double? changePercent;

  const HeroKpiCard({
    super.key,
    required this.label,
    required this.value,
    this.changePercent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: LaapakColors.surface,
        borderRadius: BorderRadius.circular(Responsive.cardRadius),
        border: Border.all(color: LaapakColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: LaapakColors.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (changePercent != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (changePercent! >= 0
                                ? LaapakColors.success
                                : LaapakColors.error)
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        changePercent! >= 0
                            ? Icons.trending_up
                            : Icons.trending_down,
                        color: changePercent! >= 0
                            ? LaapakColors.success
                            : LaapakColors.error,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${changePercent! >= 0 ? '+' : ''}${changePercent!.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: changePercent! >= 0
                              ? LaapakColors.success
                              : LaapakColors.error,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: LaapakColors.textPrimary,
              fontSize: 42,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'صافي الأداء المالي لهذا الأسبوع',
            style: TextStyle(color: LaapakColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
