/// NISA投資の詳細を表すモデルクラス
class NisaInvestment {
  final int? id; // データベースのプライマリキー
  final String name; // 投資名（例：「つみたてNISA」）
  final double initialAmount; // 初期投資額
  final double monthlyContribution; // 月々の拠出額
  final double currentValue; // 現在の評価額
  final DateTime lastUpdated; // 最終更新日
  final int contributionDay; // 毎月の拠出日

  NisaInvestment({
    this.id,
    required this.name,
    required this.initialAmount,
    required this.monthlyContribution,
    required this.currentValue,
    required this.lastUpdated,
    required this.contributionDay,
  });

  // データベースから読み込むためのファクトリメソッド
  factory NisaInvestment.fromMap(Map<String, dynamic> map) {
    return NisaInvestment(
      id: map['id'],
      name: map['name'],
      initialAmount: map['initialAmount'],
      monthlyContribution: map['monthlyContribution'],
      currentValue: map['currentValue'],
      lastUpdated: DateTime.parse(map['lastUpdated']),
      contributionDay: map['contributionDay'],
    );
  }

  // データベースに保存するためのマップに変換するメソッド
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'initialAmount': initialAmount,
      'monthlyContribution': monthlyContribution,
      'currentValue': currentValue,
      'lastUpdated': lastUpdated.toIso8601String(),
      'contributionDay': contributionDay,
    };
  }

  // オブジェクトのコピーを作成するメソッド
  NisaInvestment copyWith({
    int? id,
    String? name,
    double? initialAmount,
    double? monthlyContribution,
    double? currentValue,
    DateTime? lastUpdated,
    int? contributionDay,
  }) {
    return NisaInvestment(
      id: id ?? this.id,
      name: name ?? this.name,
      initialAmount: initialAmount ?? this.initialAmount,
      monthlyContribution: monthlyContribution ?? this.monthlyContribution,
      currentValue: currentValue ?? this.currentValue,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      contributionDay: contributionDay ?? this.contributionDay,
    );
  }
}
