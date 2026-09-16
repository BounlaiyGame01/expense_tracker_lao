import '../models/transaction_model.dart';

/// DEMO MODE: TransactionService keeps data in memory only (no MySQL/API).
/// Same public interface as the real version. Seeded with a few sample
/// transactions for this month so the UI has something to show.
class TransactionService {
  static final List<TransactionModel> _store = [];
  static int _nextId = 1;

  Future<int> add(TransactionModel tx) async {
    final id = _nextId++;
    _store.add(TransactionModel(
      id: id,
      type: tx.type,
      amount: tx.amount,
      categoryId: tx.categoryId,
      date: tx.date,
      note: tx.note,
    ));
    return id;
  }

  Future<int> update(TransactionModel tx) async {
    final index = _store.indexWhere((t) => t.id == tx.id);
    if (index != -1) _store[index] = tx;
    return tx.id!;
  }

  Future<int> delete(int id) async {
    _store.removeWhere((t) => t.id == id);
    return id;
  }

  Future<List<TransactionModel>> getAll() async {
    final list = List<TransactionModel>.from(_store);
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Future<List<TransactionModel>> getForMonth(int year, int month) async {
    final all = await getAll();
    return all.where((t) => t.date.year == year && t.date.month == month).toList();
  }

  double computeBalance(List<TransactionModel> txs) {
    double balance = 0;
    for (final t in txs) {
      balance += t.type == TxType.income ? t.amount : -t.amount;
    }
    return balance;
  }

  double totalByType(List<TransactionModel> txs, TxType type) {
    return txs.where((t) => t.type == type).fold(0.0, (sum, t) => sum + t.amount);
  }

  Map<int, double> expenseByCategory(List<TransactionModel> txs) {
    final Map<int, double> result = {};
    for (final t in txs.where((t) => t.type == TxType.expense)) {
      result[t.categoryId] = (result[t.categoryId] ?? 0) + t.amount;
    }
    return result;
  }

  /// Fills the in-memory store with a few realistic sample transactions
  /// for the current month, the first time it's empty. Category ids match
  /// the order default categories are seeded in (1=Food, 2=Transport,
  /// 3=Education, 4=Shopping, 5=Entertainment, 6=Bills, 7=Health, 8=Other,
  /// 9=Salary/Allowance, 10=Gift, 11=Part-time job).
  Future<void> seedSampleIfEmpty() async {
    if (_store.isNotEmpty) return;
    final now = DateTime.now();
    DateTime d(int day) => DateTime(now.year, now.month, day.clamp(1, 28));

    final samples = <TransactionModel>[
      TransactionModel(type: TxType.income, amount: 3000000, categoryId: 9, date: d(1), note: 'Monthly allowance'),
      TransactionModel(type: TxType.expense, amount: 250000, categoryId: 1, date: d(2), note: 'Groceries'),
      TransactionModel(type: TxType.expense, amount: 50000, categoryId: 2, date: d(3), note: 'Bus fare'),
      TransactionModel(type: TxType.expense, amount: 300000, categoryId: 4, date: d(5), note: 'New shoes'),
      TransactionModel(type: TxType.income, amount: 500000, categoryId: 11, date: d(6), note: 'Part-time pay'),
      TransactionModel(type: TxType.expense, amount: 150000, categoryId: 5, date: d(7), note: 'Movie night'),
      TransactionModel(type: TxType.expense, amount: 400000, categoryId: 6, date: d(8), note: 'Internet bill'),
      TransactionModel(type: TxType.expense, amount: 200000, categoryId: 1, date: d(9), note: 'Lunch with friends'),
      TransactionModel(type: TxType.expense, amount: 100000, categoryId: 2, date: d(10), note: 'Taxi'),
      TransactionModel(type: TxType.expense, amount: 80000, categoryId: 7, date: d(11), note: 'Pharmacy'),
    ];

    for (final tx in samples) {
      await add(tx);
    }
  }
}
