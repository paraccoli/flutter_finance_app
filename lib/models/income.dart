/// 収入カテゴリを定義する列挙型
enum IncomeCategory {
  salary('給与'),
  bonus('ボーナス'),
  investment('投資収入'),
  sideJob('副業'),
  gift('贈与・臨時収入'),
  other('その他');

  final String displayName;
  const IncomeCategory(this.displayName);

  @override
  String toString() => displayName;
}

/// 収入の詳細を表すモデルクラス
class Income {
  final int? id; // データベースのプライマリキー
  final double amount; // 金額
  final DateTime date; // 日付
  final IncomeCategory category; // カテゴリ
  final String? note; // メモ（オプション）

  Income({
    this.id,
    required this.amount,
    required this.date,
    required this.category,
    this.note,
  });

  // データベースから読み込むためのファクトリメソッド
  factory Income.fromMap(Map<String, dynamic> map) {
    return Income(
      id: map['id'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      category: IncomeCategory.values[map['category']],
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
  Income copyWith({
    int? id,
    double? amount,
    DateTime? date,
    IncomeCategory? category,
    String? note,
  }) {
    return Income(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      note: note ?? this.note,
    );
  }
}
