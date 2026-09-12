import 'package:flutter/material.dart';
import '../models/budget_model.dart';
import '../models/category_model.dart';
import '../theme/app_theme.dart';
import 'formatters.dart';

class BudgetProgressCard extends StatelessWidget {
  final BudgetModel budget;
  final CategoryModel? category;
  final double spent;
  final double percent;
  final bool isAlert;
  final VoidCallback? onEdit;

  const BudgetProgressCard({
    super.key,
    required this.budget,
    required this.category,
    required this.spent,
    required this.percent,
    required this.isAlert,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = (percent / 100).clamp(0.0, 1.0);
    final barColor = isAlert ? AppColors.warning : AppColors.primaryBlue;
    final remaining = budget.amount - spent;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(IconMapper.iconFor(category?.iconName ?? 'other'),
                    color: category?.color ?? AppColors.textGrey, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(category?.name ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18, color: AppColors.textGrey),
                  onPressed: onEdit,
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: clamped,
                minHeight: 10,
                backgroundColor: AppColors.paleBlue,
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${formatLak(spent)} / ${formatLak(budget.amount)}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                Text('${percent.toStringAsFixed(0)}%',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isAlert ? AppColors.warning : AppColors.primaryBlue)),
              ],
            ),
            if (isAlert)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  remaining >= 0
                      ? '⚠ Budget alert: remaining ${formatLak(remaining)}'
                      : '⚠ Over budget by ${formatLak(-remaining)}',
                  style: const TextStyle(color: AppColors.warning, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
