import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/nisa_investment.dart';

class NisaPerformanceAnalysis extends StatelessWidget {
  final NisaInvestment investment;
  final NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'ja_JP',
    symbol: '¥',
    decimalDigits: 0,
  );

  NisaPerformanceAnalysis({super.key, required this.investment});

  @override
  Widget build(BuildContext context) {
    // 投資パフォーマンス指標を計算
    final returnRate = investment.calculateReturnRate();
    final effectiveReturn = investment.calculateEffectiveReturnRate();
    final totalContribution = investment.calculateTotalContribution();

    // 利益率に応じた色
    final returnColor = returnRate >= 0 ? Colors.green : Colors.red;

    // 購入日からの経過月数
    final purchaseDate = investment.purchaseDate;
    final today = DateTime.now();
    final months =
        (today.year - purchaseDate.year) * 12 +
        today.month -
        purchaseDate.month; // 月次積立額がある場合の10年後と20年後の予測
    Widget forecastWidget;

    if (investment.monthlyContribution > 0) {
      final forecast10Years = investment.predictFutureValue(months: 120); // 10年
      final forecast20Years = investment.predictFutureValue(months: 240); // 20年
      forecastWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const Text(
            '積立継続時の将来予測',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          _buildForecastRow('10年後予測額', forecast10Years),
          const SizedBox(height: 4),
          _buildForecastRow('20年後予測額', forecast20Years),
          const SizedBox(height: 4),
          Text(
            '※ 現在のリターン率(${returnRate.toStringAsFixed(2)}%)が継続した場合の予測',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      );
    } else {
      forecastWidget = const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              investment.stockName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              investment.ticker,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 16),

            // 現在の投資状況
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('投資期間'),
                    Text(
                      '$months ヶ月',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('累計投資額'),
                    Text(
                      currencyFormat.format(totalContribution),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // パフォーマンス
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('投資リターン'),
                    Text(
                      '${returnRate.toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: returnColor,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('実効リターン'),
                    Text(
                      '${effectiveReturn.toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: returnColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 現在の評価額と評価損益
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('現在評価額'),
                    Text(
                      currencyFormat.format(investment.currentValue),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('評価損益'),
                    Text(
                      currencyFormat.format(
                        investment.currentValue - totalContribution,
                      ),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: returnColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // 積立設定があれば積立情報も表示
            if (investment.monthlyContribution > 0) ...[
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('毎月積立額'),
                  Text(
                    currencyFormat.format(investment.monthlyContribution),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('積立日'),
                  Text(
                    '毎月${investment.contributionDay}日',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],

            // 将来予測
            forecastWidget,
          ],
        ),
      ),
    );
  }

  Widget _buildForecastRow(String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        Text(
          currencyFormat.format(value),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }
}
