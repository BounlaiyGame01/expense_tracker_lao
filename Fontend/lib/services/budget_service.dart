import '../models/budget_model.dart';

/// DEMO MODE: BudgetService keeps data in memory only (no MySQL/API).
/// Same public interface as the real version, plus the 80%-alert rule.
class BudgetService {
  static final List<BudgetModel> _store = [];
  static int _nextId = 1;

  Future<int> add(BudgetModel budget) async {
    final id = _nextId++;
    _store.add(BudgetModel(
      id: id,
      categoryId: budget.categoryId,
      month: budget.month,
      year: budget.year,
      amount: budget.amount,
    ));
    return id;
  }

  Future<int> update(BudgetModel budget) async {
    final index = _store.indexWhere((b) => b.id == budget.id);
    if (index != -1) _store[index] = budget;
    return budget.id!;
  }

  Future<int> delete(int id) async {
    _store.removeWhere((b) => b.id == id);
    return id;
  }

  Future<List<BudgetModel>> getForMonth(int year, int month) async {
    return _store.where((b) => b.year == year && b.month == month).toList();
  }

  double percentUsed({required double spent, required double budgetAmount}) {
    if (budgetAmount <= 0) return 0;
    return (spent / budgetAmount) * 100;
  }

  bool shouldAlert({required double spent, required double budgetAmount}) {
    return percentUsed(spent: spent, budgetAmount: budgetAmount) >= 80;
  }

  /// Fills the in-memory store with sample budgets for the current month,
  /// the first time it's empty. Category ids: 1=Food, 2=Transport, 4=Shopping.
  Future<void> seedSampleIfEmpty() async {
    if (_store.isNotEmpty) return;
    final now = DateTime.now();
    final samples = <BudgetModel>[
      BudgetModel(categoryId: 1, month: now.month, year: now.year, amount: 500000), // Food
      BudgetModel(categoryId: 2, month: now.month, year: now.year, amount: 200000), // Transport
      BudgetModel(categoryId: 4, month: now.month, year: now.year, amount: 400000), // Shopping
    ];
    for (final b in samples) {
      await add(b);
    }
  }
}
