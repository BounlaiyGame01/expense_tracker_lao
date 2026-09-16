import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/formatters.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final byCategory = state.monthExpenseByCategory;
    final total = byCategory.values.fold(0.0, (a, b) => a + b);

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Spending by Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          if (byCategory.isEmpty)
            const _EmptyState(text: 'No expenses this month yet.')
          else
            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: byCategory.entries.map((e) {
                    final cat = state.categoryById(e.key);
                    final pct = total > 0 ? (e.value / total) * 100 : 0;
                    return PieChartSectionData(
                      value: e.value,
                      color: cat?.color ?? AppColors.textGrey,
                      title: '${pct.toStringAsFixed(0)}%',
                      radius: 60,
                      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    );
                  }).toList(),
                ),
              ),
            ),
          const SizedBox(height: 12),
          if (byCategory.isNotEmpty)
            ...(byCategory.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
                .map((e) {
              final cat = state.categoryById(e.key);
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(width: 10, height: 10, decoration: BoxDecoration(color: cat?.color ?? AppColors.textGrey, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(cat?.name ?? 'Unknown')),
                    Text(formatLak(e.value), style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              );
            }),
          const SizedBox(height: 28),
          const Text('Income vs Expense (This Month)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: [state.monthIncome, state.monthExpense].reduce((a, b) => a > b ? a : b) * 1.2 + 1,
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final text = value == 0 ? 'Income' : (value == 1 ? 'Expense' : '');
                        return Padding(padding: const EdgeInsets.only(top: 6), child: Text(text));
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [
                    BarChartRodData(toY: state.monthIncome, color: AppColors.income, width: 36, borderRadius: BorderRadius.circular(6)),
                  ]),
                  BarChartGroupData(x: 1, barRods: [
                    BarChartRodData(toY: state.monthExpense, color: AppColors.expense, width: 36, borderRadius: BorderRadius.circular(6)),
                  ]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String text;
  const _EmptyState({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: AppColors.paleBlue, borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: const TextStyle(color: AppColors.textGrey)),
    );
  }
}
