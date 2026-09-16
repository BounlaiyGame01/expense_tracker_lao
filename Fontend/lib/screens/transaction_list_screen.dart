import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/transaction_model.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/formatters.dart';
import 'add_transaction_screen.dart';

class TransactionListScreen extends StatelessWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final txs = [...state.allTransactions]..sort((a, b) => b.date.compareTo(a.date));

    // Group by day label (Today / Yesterday / date)
    final Map<String, List<TransactionModel>> grouped = {};
    for (final t in txs) {
      final key = formatDayLabel(t.date);
      grouped.putIfAbsent(key, () => []).add(t);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('All Transactions')),
      body: txs.isEmpty
          ? const Center(child: Text('No transactions yet.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: grouped.entries.expand((entry) {
                return [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(entry.key,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  ),
                  ...entry.value.map((tx) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TransactionTile(
                          tx: tx,
                          category: state.categoryById(tx.categoryId),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => AddTransactionScreen(existing: tx)),
                          ),
                          onDelete: () => state.deleteTransaction(tx.id!),
                        ),
                      )),
                ];
              }).toList(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
