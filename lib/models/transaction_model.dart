enum TxType { income, expense }

class TransactionModel {
  final int? id;
  final TxType type;
  final double amount;
  final int categoryId;
  final DateTime date;
  final String note;

  TransactionModel({
    this.id,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.note = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'amount': amount,
      'category_id': categoryId,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      type: (map['type'] as String) == 'income' ? TxType.income : TxType.expense,
      amount: (map['amount'] as num).toDouble(),
      categoryId: map['category_id'] as int,
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String? ?? '',
    );
  }

  TransactionModel copyWith({
    TxType? type,
    double? amount,
    int? categoryId,
    DateTime? date,
    String? note,
  }) {
    return TransactionModel(
      id: id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }
}
