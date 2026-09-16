import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/formatters.dart';
import 'add_transaction_screen.dart';
import 'transaction_list_screen.dart';
import 'categories_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final recent = state.monthTransactions.take(5).toList();
    final categoryTotals = state.monthExpenseByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Budget / ງົບປະມານຂອງຂ້ອຍ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.category_outlined),
            tooltip: 'Manage Categories',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CategoriesScreen()),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => state.init(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SummaryCard(
              balance: state.balance,
              income: state.monthIncome,
              expense: state.monthExpense,
            ),
            const SizedBox(height: 20),
            const Text('This Month by Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            if (categoryTotals.isEmpty)
              const _EmptyHint(text: 'No expenses recorded yet this month.')
            else
              ...categoryTotals.take(5).map((entry) {
                final cat = state.categoryById(entry.key);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 10, height: 10,
                        decoration: BoxDecoration(color: cat?.color ?? AppColors.textGrey, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(cat?.name ?? 'Unknown')),
                      Text(formatLak(entry.value), style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                );
              }),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Transactions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TransactionListScreen()),
                  ),
                  child: const Text('See all'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (recent.isEmpty)
              const _EmptyHint(text: 'No transactions yet. Tap + to add one.')
            else
              ...recent.map((tx) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TransactionTile(
                      tx: tx,
                      category: state.categoryById(tx.categoryId),
                      onDelete: () => state.deleteTransaction(tx.id!),
                    ),
                  )),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.paleBlue, borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: const TextStyle(color: AppColors.textGrey)),
    );
  }
}
