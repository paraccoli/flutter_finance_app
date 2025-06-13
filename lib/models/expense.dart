import 'package:flutter/material.dart';

/// 支出カテゴリを定義する列挙型
enum ExpenseCategory {
  food('食費', Colors.orange, Icons.fastfood),
  transportation('交通費', Colors.blue, Icons.directions_bus),
  entertainment('娯楽', Colors.purple, Icons.movie),
  utilities('光熱費', Colors.yellow, Icons.flash_on),
  shopping('買い物', Colors.pink, Icons.shopping_bag),
  health('健康・医療', Colors.red, Icons.favorite),
  education('教育', Colors.green, Icons.school),
  rent('家賃', Colors.brown, Icons.home),
  other('その他', Colors.grey, Icons.category);

  final String displayName;
  final Color color;
  final IconData icon;

  const ExpenseCategory(this.displayName, this.color, this.icon);

  @override
  String toString() => displayName;
}

/// 支出の詳細を表すモデルクラス
class Expense {
  final int? id; // データベースのプライマリキー
  final double amount; // 金額
  final DateTime date; // 日付
  final ExpenseCategory category; // カテゴリ
  final String? note; // メモ（オプション）

  Expense({
    this.id,
    required this.amount,
    required this.date,
    required this.category,
    this.note,
  });

  // データベースから読み込むためのファクトリメソッド
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      category: ExpenseCategory.values[map['category']],
      note: map['note'],
    );
  }

  // データベースに保存するためのマップに変換するメソッド
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category.index,
      'note': note,
    };
  }

  // オブジェクトのコピーを作成するメソッド
  Expense copyWith({
    int? id,
    double? amount,
    DateTime? date,
    ExpenseCategory? category,
    String? note,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      note: note ?? this.note,
    );
  }
}
