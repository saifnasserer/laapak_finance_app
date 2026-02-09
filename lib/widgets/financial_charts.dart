import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:laapak_finance/theme/colors.dart';

class TrendChart extends StatelessWidget {
  final List<String> labels;
  final List<double> revenue;
  final List<double> expenses;

  const TrendChart({
    super.key,
    required this.labels,
    required this.revenue,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    if (revenue.isEmpty) {
      return const Center(
        child: Text(
          'لا يوجد بيانات',
          style: TextStyle(color: LaapakColors.textSecondary),
        ),
      );
    }

    // Determine Y-axis max for scaling
    final List<double> allValues = [...revenue, ...expenses];
    final double maxValue = allValues.isNotEmpty
        ? allValues.reduce((a, b) => a > b ? a : b)
        : 0.0;
    final maxY = maxValue == 0 ? 10.0 : maxValue * 1.2;
    final interval = maxY / 5 > 0 ? maxY / 5 : 1.0;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (value) {
            return const FlLine(color: LaapakColors.border, strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < labels.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      labels[index],
                      style: const TextStyle(
                        color: LaapakColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: interval,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const Text('');
                return Text(
                  _formatCompact(value),
                  style: const TextStyle(
                    color: LaapakColors.textSecondary,
                    fontSize: 10,
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (labels.length - 1).toDouble(),
        minY: 0,
        maxY: maxY,
        lineBarsData: [
          // Revenue Line
          LineChartBarData(
            spots: List.generate(
              revenue.length,
              (i) => FlSpot(i.toDouble(), revenue[i]),
            ),
            isCurved: true,
            color: LaapakColors.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: LaapakColors.primary.withOpacity(0.1),
            ),
          ),
          // Expenses Line
          LineChartBarData(
            spots: List.generate(
              expenses.length,
              (i) => FlSpot(i.toDouble(), expenses[i]),
            ),
            isCurved: true,
            color: LaapakColors.error,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            dashArray: [5, 5],
          ),
        ],
      ),
    );
  }

  String _formatCompact(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}k';
    return value.toInt().toString();
  }
}

class ExpenseChart extends StatelessWidget {
  final Map<String, double> data; // Category -> Value

  const ExpenseChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text(
          'لا يوجد بيانات',
          style: TextStyle(color: LaapakColors.textSecondary),
        ),
      );
    }

    final total = data.values.fold(0.0, (sum, val) => sum + val);

    if (total == 0) {
      return const Center(
        child: Text(
          'لا يوجد مبالغ مستحقة',
          style: TextStyle(color: LaapakColors.textSecondary),
        ),
      );
    }

    // Convert map to list for indexing colors
    final entries = data.entries.toList();
    final colors = [
      LaapakColors.primary,
      const Color(0xFF198754),
      const Color(0xFF20C997),
      LaapakColors.warning,
      LaapakColors.error,
      LaapakColors.textSecondary,
    ];

    return Row(
      children: [
        // Pie Chart
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 40,
                sections: List.generate(entries.length, (i) {
                  final entry = entries[i];
                  final isLarge = entry.value / total > 0.15;
                  return PieChartSectionData(
                    color: colors[i % colors.length],
                    value: entry.value,
                    title: isLarge
                        ? '${(entry.value / total * 100).toStringAsFixed(0)}%'
                        : '',
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
        // Legend
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(entries.length, (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colors[i % colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entries[i].key,
                        style: const TextStyle(
                          fontSize: 12,
                          color: LaapakColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
