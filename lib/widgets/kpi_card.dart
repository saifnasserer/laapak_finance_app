import 'package:flutter/material.dart';
import 'package:laapak_finance/theme/colors.dart';
import '../utils/responsive.dart';

class KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final double? changePercent; // e.g. 5.5 for +5.5%, -2.0 for -2.0%
  final bool isCurrency;

  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    this.changePercent,
    this.isCurrency = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Responsive.cardRadius),
        side: const BorderSide(color: LaapakColors.borderLight),
      ),
      color: LaapakColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: LaapakColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(
                  color: LaapakColors.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ),
            if (changePercent != null) ...[
              const SizedBox(height: 4),
              _TrendIndicator(percent: changePercent!),
            ],
          ],
        ),
      ),
    );
  }
}

class _TrendIndicator extends StatelessWidget {
  final double percent;

  const _TrendIndicator({required this.percent});

  @override
  Widget build(BuildContext context) {
    final isPositive = percent > 0;
    final isNeutral = percent == 0;
    final color = isNeutral
        ? LaapakColors.textSecondary
        : (isPositive ? LaapakColors.success : LaapakColors.error);

    final icon = isNeutral
        ? Icons.remove
        : (isPositive ? Icons.arrow_upward : Icons.arrow_downward);

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            '${percent.abs().toStringAsFixed(1)}%',
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          if (!isNeutral)
            Text(
              'عن الأسبوع الماضي',
              style: const TextStyle(
                color: LaapakColors.textSecondary,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }
}
