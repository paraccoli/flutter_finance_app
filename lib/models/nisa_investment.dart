/// NISA投資の詳細を表すモデルクラス
class NisaInvestment {
  final int? id; // データベースのプライマリーキー
  final String stockName; // 株式名
  final String ticker; // ティッカーシンボル
  final double investedAmount; // 投資額
  final double currentValue; // 現在の評価額
  final DateTime purchaseDate; // 購入日
  final double monthlyContribution; // 月々の拠出額
  final int contributionDay; // 拠出日（毎月何日）
  final DateTime lastUpdated; // 最終更新日

  NisaInvestment({
    this.id,
    required this.stockName,
    required this.ticker,
    required this.investedAmount,
    required this.currentValue,
    required this.purchaseDate,
    required this.monthlyContribution,
    required this.contributionDay,
    required this.lastUpdated,
  });

  // データベースから読み込むためのファクトリメソッド
  factory NisaInvestment.fromMap(Map<String, dynamic> map) {
    final String stockName = map['stockName'] ?? map['name'] ?? '未設定';
    final String ticker = map['ticker'] ?? '';
    final double investedAmount =
        map['investedAmount'] ?? map['initialAmount'] ?? 0.0;
    final double currentValue = map['currentValue'] ?? 0.0;
    final DateTime purchaseDate = map['purchaseDate'] != null
        ? DateTime.parse(map['purchaseDate'])
        : DateTime.parse(
            map['lastUpdated'] ?? DateTime.now().toIso8601String(),
          );
    final double monthlyContribution = map['monthlyContribution'] ?? 0.0;
    final int contributionDay = map['contributionDay'] ?? 1;
    final DateTime lastUpdated = map['lastUpdated'] != null
        ? DateTime.parse(map['lastUpdated'])
        : DateTime.now();

    return NisaInvestment(
      id: map['id'],
      stockName: stockName,
      ticker: ticker,
      investedAmount: investedAmount,
      currentValue: currentValue,
      purchaseDate: purchaseDate,
      monthlyContribution: monthlyContribution,
      contributionDay: contributionDay,
      lastUpdated: lastUpdated,
    );
  }

  // データベースに保存するためのマップに変換するメソッド
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'stockName': stockName,
      'ticker': ticker,
      'investedAmount': investedAmount,
      'currentValue': currentValue,
      'purchaseDate': purchaseDate.toIso8601String(),
      'monthlyContribution': monthlyContribution,
      'contributionDay': contributionDay,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  // オブジェクトのコピーを作成するメソッド
  NisaInvestment copyWith({
    int? id,
    String? stockName,
    String? ticker,
    double? investedAmount,
    double? currentValue,
    DateTime? purchaseDate,
    double? monthlyContribution,
    int? contributionDay,
    DateTime? lastUpdated,
  }) {
    return NisaInvestment(
      id: id ?? this.id,
      stockName: stockName ?? this.stockName,
      ticker: ticker ?? this.ticker,
      investedAmount: investedAmount ?? this.investedAmount,
      currentValue: currentValue ?? this.currentValue,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      monthlyContribution: monthlyContribution ?? this.monthlyContribution,
      contributionDay: contributionDay ?? this.contributionDay,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // 投資の利回りを計算するメソッド
  double calculateReturnRate() {
    if (investedAmount <= 0) return 0.0;
    return ((currentValue - investedAmount) / investedAmount) * 100;
  }

  // 累積拠出額を計算するメソッド（最初の投資額＋毎月の積立累計）
  double calculateTotalContribution() {
    final now = DateTime.now();
    // 購入日からの経過月数を計算
    final months =
        (now.year - purchaseDate.year) * 12 + now.month - purchaseDate.month;
    // 毎月の拠出額×経過月数+初期投資額
    return investedAmount + (monthlyContribution * months);
  }

  // 実質利回りを計算（累積拠出額に対する現在価値の利回り）
  double calculateEffectiveReturnRate() {
    final totalContribution = calculateTotalContribution();
    if (totalContribution <= 0) return 0.0;
    return ((currentValue - totalContribution) / totalContribution) * 100;
  }

  // 将来価値を予測するメソッド
  double predictFutureValue({
    required int months,
    double annualGrowthRate = 0.05, // デフォルト5%
  }) {
    final monthlyRate = annualGrowthRate / 12;
    double futureValue = currentValue;

    // 毎月の拠出と成長を計算
    for (int i = 0; i < months; i++) {
      futureValue = futureValue * (1 + monthlyRate) + monthlyContribution;
    }

    return futureValue;
  }

  // 月次のパフォーマンス予測データを生成（チャート表示用）
  List<double> generateMonthlyForecastData(
    int months, {
    double annualGrowthRate = 0.05,
  }) {
    final monthlyRate = annualGrowthRate / 12;
    final List<double> forecastData = [];

    double accumulatedValue = currentValue;
    // 現在の値をリストに追加
    forecastData.add(accumulatedValue);

    for (int i = 0; i < months; i++) {
      // 資産成長を計算
      accumulatedValue =
          accumulatedValue * (1 + monthlyRate) + monthlyContribution;

      // 累積価値を追加
      forecastData.add(accumulatedValue);
    }

    return forecastData;
  }

  // 資産構成データを取得（円グラフ表示用）
  Map<String, double> getAssetComposition() {
    // 簡易的な実装 - 実際のアプリでは資産の詳細情報を追加
    return {
      '元本': investedAmount,
      '運用益': currentValue > investedAmount ? currentValue - investedAmount : 0,
      '評価損': currentValue < investedAmount ? investedAmount - currentValue : 0,
    };
  }
}