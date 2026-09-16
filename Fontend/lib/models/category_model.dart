import 'package:flutter/material.dart';

enum CategoryType { income, expense }

class CategoryModel {
  final int? id;
  final String name;
  final String iconName; // maps to Icons via IconMapper
  final int colorValue; // stored as ARGB int in DB
  final CategoryType type;

  CategoryModel({
    this.id,
    required this.name,
    required this.iconName,
    required this.colorValue,
    required this.type,
  });

  Color get color => Color(colorValue);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon_name': iconName,
      'color_value': colorValue,
      'type': type.name,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      iconName: map['icon_name'] as String,
      colorValue: map['color_value'] as int,
      type: (map['type'] as String) == 'income' ? CategoryType.income : CategoryType.expense,
    );
  }

  CategoryModel copyWith({String? name, String? iconName, int? colorValue}) {
    return CategoryModel(
      id: id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      colorValue: colorValue ?? this.colorValue,
      type: type,
    );
  }
}

/// Maps a stored icon-name string to a Flutter IconData.
/// Kept centralized so the DB only ever stores plain strings.
class IconMapper {
  static const Map<String, IconData> _map = {
    'food': Icons.restaurant,
    'transport': Icons.directions_bus,
    'education': Icons.school,
    'shopping': Icons.shopping_bag,
    'entertainment': Icons.movie,
    'bills': Icons.receipt_long,
    'health': Icons.local_hospital,
    'other': Icons.category,
    'salary': Icons.account_balance_wallet,
    'gift': Icons.card_giftcard,
    'parttime': Icons.work,
  };

  static IconData iconFor(String name) => _map[name] ?? Icons.category;

  static List<String> get allKeys => _map.keys.toList();
}

/// Default categories seeded on first app run.
List<CategoryModel> defaultCategories() {
  return [
    CategoryModel(name: 'Food', iconName: 'food', colorValue: 0xFFE57373, type: CategoryType.expense),
    CategoryModel(name: 'Transport', iconName: 'transport', colorValue: 0xFF64B5F6, type: CategoryType.expense),
    CategoryModel(name: 'Education', iconName: 'education', colorValue: 0xFF9575CD, type: CategoryType.expense),
    CategoryModel(name: 'Shopping', iconName: 'shopping', colorValue: 0xFFFFB74D, type: CategoryType.expense),
    CategoryModel(name: 'Entertainment', iconName: 'entertainment', colorValue: 0xFF4DB6AC, type: CategoryType.expense),
    CategoryModel(name: 'Bills', iconName: 'bills', colorValue: 0xFF90A4AE, type: CategoryType.expense),
    CategoryModel(name: 'Health', iconName: 'health', colorValue: 0xFFF06292, type: CategoryType.expense),
    CategoryModel(name: 'Other', iconName: 'other', colorValue: 0xFFA1887F, type: CategoryType.expense),
    CategoryModel(name: 'Salary/Allowance', iconName: 'salary', colorValue: 0xFF388E3C, type: CategoryType.income),
    CategoryModel(name: 'Gift', iconName: 'gift', colorValue: 0xFF7CB342, type: CategoryType.income),
    CategoryModel(name: 'Part-time job', iconName: 'parttime', colorValue: 0xFF00897B, type: CategoryType.income),
  ];
}
