import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../theme/app_theme.dart';
import '../widgets/formatters.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? existing; // non-null = edit mode

  const AddTransactionScreen({super.key, this.existing});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  TxType _type = TxType.expense;
  CategoryModel? _selectedCategory;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _type = e.type;
      _amountController.text = e.amount.toStringAsFixed(0);
      _noteController.text = e.note;
      _date = e.date;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final categoryOptions = state.categories
        .where((c) => c.type == (_type == TxType.income ? CategoryType.income : CategoryType.expense))
        .toList();

    _selectedCategory ??= widget.existing != null
        ? state.categoryById(widget.existing!.categoryId)
        : (categoryOptions.isNotEmpty ? categoryOptions.first : null);

    if (_selectedCategory != null && !categoryOptions.contains(_selectedCategory)) {
      _selectedCategory = categoryOptions.isNotEmpty ? categoryOptions.first : null;
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.existing == null ? 'Add Transaction' : 'Edit Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Income / Expense toggle
              Container(
                decoration: BoxDecoration(color: AppColors.paleBlue, borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(child: _typeButton('Expense', TxType.expense)),
                    Expanded(child: _typeButton('Income', TxType.income)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount (LAK)', prefixIcon: Icon(Icons.payments)),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Please enter an amount';
                  if (double.tryParse(v) == null) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<CategoryModel>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category', prefixIcon: Icon(Icons.category)),
                items: categoryOptions
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v),
                validator: (v) => v == null ? 'Please choose a category' : null,
              ),
              const SizedBox(height: 12),
              ListTile(
                tileColor: AppColors.paleBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: const Icon(Icons.calendar_today, color: AppColors.primaryBlue),
                title: Text(formatDate(_date)),
                onTap: _pickDate,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'Note (optional)', prefixIcon: Icon(Icons.edit_note)),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _save,
                child: Text(widget.existing == null ? 'Save Transaction' : 'Update Transaction'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeButton(String label, TxType type) {
    final selected = _type == type;
    return GestureDetector(
      onTap: () => setState(() {
        _type = type;
        _selectedCategory = null;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _selectedCategory == null) return;
    final state = context.read<AppState>();
    final tx = TransactionModel(
      id: widget.existing?.id,
      type: _type,
      amount: double.parse(_amountController.text),
      categoryId: _selectedCategory!.id!,
      date: _date,
      note: _noteController.text.trim(),
    );

    if (widget.existing == null) {
      await state.addTransaction(tx);
    } else {
      await state.updateTransaction(tx);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}
