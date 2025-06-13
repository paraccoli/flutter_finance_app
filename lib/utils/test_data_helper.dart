import '../models/nisa_investment.dart';

/// テストデータを生成するヘルパークラス
class TestDataHelper {
  // 支出テストデータ
  static List<Map<String, dynamic>> getExpenseTestData() {
    return [
      {'amount': 3200, 'date': '2025-06-01', 'category': 'food'},
      {'amount': 1500, 'date': '2025-06-02', 'category': 'transportation'},
      {'amount': 7800, 'date': '2025-06-03', 'category': 'entertainment'},
      {'amount': 4600, 'date': '2025-06-04', 'category': 'utilities'},
      {'amount': 12000, 'date': '2025-06-05', 'category': 'shopping'},
      {'amount': 2500, 'date': '2025-06-07', 'category': 'healthcare'},
      {'amount': 6000, 'date': '2025-06-10', 'category': 'education'},
      {'amount': 3800, 'date': '2025-06-12', 'category': 'food'},
      {'amount': 2000, 'date': '2025-06-13', 'category': 'other'},
      {'amount': 1200, 'date': '2025-06-14', 'category': 'transportation'},
      {'amount': 5500, 'date': '2025-06-17', 'category': 'entertainment'},
      {'amount': 9000, 'date': '2025-06-19', 'category': 'shopping'},
      {'amount': 3000, 'date': '2025-06-21', 'category': 'utilities'},
      {'amount': 4200, 'date': '2025-06-22', 'category': 'food'},
      {'amount': 1500, 'date': '2025-06-23', 'category': 'other'},
      {'amount': 2700, 'date': '2025-06-25', 'category': 'healthcare'},
      {'amount': 3400, 'date': '2025-06-27', 'category': 'education'},
    ];
  }

  // 収入テストデータ
  static List<Map<String, dynamic>> getIncomeTestData() {
    return [
      {'amount': 280000, 'date': '2025-06-01', 'category': 'salary'},
      {'amount': 100000, 'date': '2025-06-05', 'category': 'bonus'},
      {'amount': 12000, 'date': '2025-06-11', 'category': 'investment'},
      {'amount': 20000, 'date': '2025-06-15', 'category': 'sideJob'},
      {'amount': 5000, 'date': '2025-06-18', 'category': 'gift'},
      {'amount': 3000, 'date': '2025-06-22', 'category': 'other'},
    ];
  }
  // NISAテストデータ
  static List<NisaInvestment> getNisaTestData() {
    // 2025年6月を基準とするテストデータ
    final baseDate = DateTime(2025, 6, 7);

    return [
      NisaInvestment(
        stockName: 'eMAXIS Slim 米国株式',
        ticker: 'EMXUS',
        investedAmount: 100000,
        currentValue: 145000,
        purchaseDate: DateTime(2024, 1, 5),
        monthlyContribution: 33333,
        contributionDay: 5,
        lastUpdated: baseDate,
      ),
      NisaInvestment(
        stockName: '楽天・全世界株式',
        ticker: 'RAKWLD',
        investedAmount: 50000,
        currentValue: 85500,
        purchaseDate: DateTime(2024, 2, 5),
        monthlyContribution: 20000,
        contributionDay: 5,
        lastUpdated: baseDate,
      ),
      NisaInvestment(
        stockName: 'SBI-S&P500',
        ticker: 'SBISP5',
        investedAmount: 80000,
        currentValue: 126000,
        purchaseDate: DateTime(2024, 3, 5),
        monthlyContribution: 25000,
        contributionDay: 5,
        lastUpdated: baseDate,
      ),
    ];
  }

  // テストデータをCSV形式で出力
  static String exportTestDataAsCsv() {
    final buffer = StringBuffer();

    // 支出データヘッダー
    buffer.writeln('-- 支出データ --');
    buffer.writeln('金額（円）,日付,カテゴリ');

    for (final expense in getExpenseTestData()) {
      buffer.writeln(
        '${expense['amount']},${expense['date']},${expense['category']}',
      );
    }

    buffer.writeln('\n-- 収入データ --');
    buffer.writeln('金額（円）,日付,カテゴリ');

    for (final income in getIncomeTestData()) {
      buffer.writeln(
        '${income['amount']},${income['date']},${income['category']}',
      );
    }

    buffer.writeln('\n-- NISA投資データ --');
    buffer.writeln('投資名,初期投資額（円）,月々の拠出額（円）,現在の評価額（円）,最終更新日,毎月の拠出日');

    for (final nisa in getNisaTestData()) {
      buffer.writeln(
        '${nisa.stockName},${nisa.investedAmount},${nisa.monthlyContribution},${nisa.currentValue},${nisa.lastUpdated.toString().split(' ')[0]},${nisa.contributionDay}',
      );
    }

    return buffer.toString();
  }
}
