import 'package:flutter/foundation.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../models/budget_model.dart';
import 'category_service.dart';
import 'transaction_service.dart';
import 'budget_service.dart';

/// AppState: the single object screens listen to.
/// It orchestrates the three "micro-services" (Category / Transaction / Budget)
/// and exposes ready-to-render data + simple commands (addTransaction, etc).
class AppState extends ChangeNotifier {
  final CategoryService _categoryService = CategoryService();
  final TransactionService _transactionService = TransactionService();
  final BudgetService _budgetService = BudgetService();

  List<CategoryModel> categories = [];
  List<TransactionModel> allTransactions = [];
  List<BudgetModel> currentMonthBudgets = [];

  DateTime selectedMonth = DateTime.now();
  bool isLoading = true;
  String? errorMessage;

  Future<void> init() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _categoryService.seedDefaultsIfEmpty();
      await loadCategories();
      await _transactionService.seedSampleIfEmpty();
      await loadTransactions();
      await _budgetService.seedSampleIfEmpty();
      await loadBudgets();
    } catch (e) {
      errorMessage = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  // ---------------- Categories ----------------
  Future<void> loadCategories() async {
    categories = await _categoryService.getAll();
    notifyListeners();
  }

  CategoryModel? categoryById(int id) {
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addCategory(CategoryModel category) async {
    await _categoryService.add(category);
    await loadCategories();
  }

  Future<void> deleteCategory(int id) async {
    await _categoryService.delete(id);
    await loadCategories();
  }

  // ---------------- Transactions ----------------
  Future<void> loadTransactions() async {
    allTransactions = await _transactionService.getAll();
    notifyListeners();
  }

  List<TransactionModel> get monthTransactions {
    return allTransactions.where((t) =>
        t.date.year == selectedMonth.year && t.date.month == selectedMonth.month).toList();
  }

  double get balance => _transactionService.computeBalance(allTransactions);
  double get monthIncome => _transactionService.totalByType(monthTransactions, TxType.income);
  double get monthExpense => _transactionService.totalByType(monthTransactions, TxType.expense);
  Map<int, double> get monthExpenseByCategory =>
      _transactionService.expenseByCategory(monthTransactions);

  Future<void> addTransaction(TransactionModel tx) async {
    await _transactionService.add(tx);
    await loadTransactions();
  }

  Future<void> updateTransaction(TransactionModel tx) async {
    await _transactionService.update(tx);
    await loadTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    await _transactionService.delete(id);
    await loadTransactions();
  }

  void changeMonth(DateTime month) {
    selectedMonth = DateTime(month.year, month.month);
    loadBudgets();
    notifyListeners();
  }

  // ---------------- Budgets ----------------
  Future<void> loadBudgets() async {
    currentMonthBudgets =
        await _budgetService.getForMonth(selectedMonth.year, selectedMonth.month);
    notifyListeners();
  }

  Future<void> setBudget(BudgetModel budget) async {
    // Replace existing budget for that category/month if present, else add.
    final existing = currentMonthBudgets.where((b) => b.categoryId == budget.categoryId);
    if (existing.isNotEmpty) {
      await _budgetService.update(BudgetModel(
        id: existing.first.id,
        categoryId: budget.categoryId,
        month: budget.month,
        year: budget.year,
        amount: budget.amount,
      ));
    } else {
      await _budgetService.add(budget);
    }
    await loadBudgets();
  }

  Future<void> deleteBudget(int id) async {
    await _budgetService.delete(id);
    await loadBudgets();
  }

  double spentForCategory(int categoryId) {
    return monthExpenseByCategory[categoryId] ?? 0;
  }

  double percentUsed(BudgetModel budget) {
    return _budgetService.percentUsed(
      spent: spentForCategory(budget.categoryId),
      budgetAmount: budget.amount,
    );
  }

  bool isOverThreshold(BudgetModel budget) {
    return _budgetService.shouldAlert(
      spent: spentForCategory(budget.categoryId),
      budgetAmount: budget.amount,
    );
  }
}
