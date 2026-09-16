import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/budget_model.dart';
import '../models/category_model.dart';
import '../theme/app_theme.dart';
import '../widgets/budget_progress_card.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final expenseCategories = state.categories.where((c) => c.type == CategoryType.expense).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Budgets')),
      body: expenseCategories.isEmpty
          ? const Center(child: Text('No categories yet.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: expenseCategories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final cat = expenseCategories[index];
                final budget = state.currentMonthBudgets
                    .where((b) => b.categoryId == cat.id)
                    .cast<BudgetModel?>()
                    .firstOrNull;

                final spent = state.spentForCategory(cat.id!);

                if (budget == null) {
                  return Card(
                    child: ListTile(
                      leading: Icon(IconMapper.iconFor(cat.iconName), color: cat.color),
                      title: Text(cat.name),
                      subtitle: const Text('No budget set'),
                      trailing: TextButton(
                        onPressed: () => _showBudgetDialog(context, state, cat, null),
                        child: const Text('Set budget'),
                      ),
                    ),
                  );
                }

                return BudgetProgressCard(
                  budget: budget,
                  category: cat,
                  spent: spent,
                  percent: state.percentUsed(budget),
                  isAlert: state.isOverThreshold(budget),
                  onEdit: () => _showBudgetDialog(context, state, cat, budget),
                );
              },
            ),
    );
  }

  void _showBudgetDialog(BuildContext context, AppState state, CategoryModel cat, BudgetModel? existing) {
    final controller = TextEditingController(text: existing?.amount.toStringAsFixed(0) ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Budget for ${cat.name}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Monthly amount (LAK)'),
        ),
        actions: [
          if (existing != null)
            TextButton(
              onPressed: () {
                state.deleteBudget(existing.id!);
                Navigator.pop(ctx);
              },
              child: const Text('Delete', style: TextStyle(color: AppColors.expense)),
            ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                state.setBudget(BudgetModel(
                  categoryId: cat.id!,
                  month: state.selectedMonth.month,
                  year: state.selectedMonth.year,
                  amount: amount,
                ));
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
