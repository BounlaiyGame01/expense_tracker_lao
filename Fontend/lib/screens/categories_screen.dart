import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/category_model.dart';
import '../theme/app_theme.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () => _showAddDialog(context, state)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionLabel('Expense Categories'),
          ...state.categories.where((c) => c.type == CategoryType.expense).map((c) => _tile(context, state, c)),
          const SizedBox(height: 16),
          _sectionLabel('Income Categories'),
          ...state.categories.where((c) => c.type == CategoryType.income).map((c) => _tile(context, state, c)),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textGrey)),
      );

  Widget _tile(BuildContext context, AppState state, CategoryModel c) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: c.color.withValues(alpha: 0.15),
          child: Icon(IconMapper.iconFor(c.iconName), color: c.color),
        ),
        title: Text(c.name),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: AppColors.expense),
          onPressed: () => state.deleteCategory(c.id!),
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context, AppState state) {
    final nameController = TextEditingController();
    CategoryType type = CategoryType.expense;
    String iconKey = 'other';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('New Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
              const SizedBox(height: 12),
              DropdownButtonFormField<CategoryType>(
                initialValue: type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: const [
                  DropdownMenuItem(value: CategoryType.expense, child: Text('Expense')),
                  DropdownMenuItem(value: CategoryType.income, child: Text('Income')),
                ],
                onChanged: (v) => setState(() => type = v ?? CategoryType.expense),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: iconKey,
                decoration: const InputDecoration(labelText: 'Icon'),
                items: IconMapper.allKeys
                    .map((k) => DropdownMenuItem(value: k, child: Row(children: [
                          Icon(IconMapper.iconFor(k), size: 18),
                          const SizedBox(width: 8),
                          Text(k),
                        ])))
                    .toList(),
                onChanged: (v) => setState(() => iconKey = v ?? 'other'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) return;
                state.addCategory(CategoryModel(
                  name: nameController.text.trim(),
                  iconName: iconKey,
                  colorValue: AppColors.primaryBlue.toARGB32(),
                  type: type,
                ));
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
