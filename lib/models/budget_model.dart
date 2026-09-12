class BudgetModel {
  final int? id;
  final int categoryId;
  final int month; // 1-12
  final int year;
  final double amount;

  BudgetModel({
    this.id,
    required this.categoryId,
    required this.month,
    required this.year,
    required this.amount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'month': month,
      'year': year,
      'amount': amount,
    };
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'] as int?,
      categoryId: map['category_id'] as int,
      month: map['month'] as int,
      year: map['year'] as int,
      amount: (map['amount'] as num).toDouble(),
    );
  }
}
