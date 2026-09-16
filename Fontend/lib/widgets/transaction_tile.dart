import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../theme/app_theme.dart';
import 'formatters.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel tx;
  final CategoryModel? category;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TransactionTile({
    super.key,
    required this.tx,
    required this.category,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = tx.type == TxType.income;
    final color = isIncome ? AppColors.income : AppColors.expense;
    final catColor = category?.color ?? AppColors.textGrey;

    return Dismissible(
      key: ValueKey(tx.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.expense,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete?.call(),
      child: Card(
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: CircleAvatar(
            backgroundColor: catColor.withValues(alpha: 0.15),
            child: Icon(IconMapper.iconFor(category?.iconName ?? 'other'), color: catColor),
          ),
          title: Text(category?.name ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: tx.note.isNotEmpty ? Text(tx.note, maxLines: 1, overflow: TextOverflow.ellipsis) : null,
          trailing: Text(
            '${isIncome ? '+' : '-'}${formatLak(tx.amount)}',
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
