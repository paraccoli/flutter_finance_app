import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/nisa_viewmodel.dart';
import '../models/nisa_investment.dart';
import '../widgets/nisa_investment_form.dart';

class NisaScreen extends StatelessWidget {
  const NisaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<NisaViewModel>(context);
    final investments = viewModel.investments;
    
    // 合計値を取得
    final totalInvested = viewModel.getTotalInvestedAmount();
    final totalCurrent = viewModel.getTotalCurrentValue();
    final totalProfit = viewModel.getTotalProfit();
    
    // 利益率の計算
    final profitRate = totalInvested > 0 
        ? (totalProfit / totalInvested) * 100 
        : 0.0;
    
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => viewModel.loadInvestments(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // サマリーカード
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'NISA投資サマリー',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSummaryRow('投資総額', totalInvested),
                        const SizedBox(height: 8),
                        _buildSummaryRow('現在評価額', totalCurrent),
                        const SizedBox(height: 8),
                        _buildSummaryRow(
                          '評価損益', 
                          totalProfit,
                          isProfit: totalProfit >= 0,
                        ),
                        const SizedBox(height: 8),
                        _buildSummaryRow(
                          '利益率', 
                          profitRate,
                          isPercentage: true,
                          isProfit: profitRate >= 0,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // 投資一覧ヘッダー
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'NISA投資一覧',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showAddInvestmentDialog(context, viewModel),
                      icon: const Icon(Icons.add),
                      label: const Text('追加'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // 投資リスト
                if (investments.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(
                        child: Text('投資データがありません'),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: investments.length,
                    itemBuilder: (context, index) {
                      final investment = investments[index];
                      return _buildInvestmentCard(context, viewModel, investment);
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddInvestmentDialog(context, viewModel),
        tooltip: '投資を追加',
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildSummaryRow(String label, double value, {
    bool isPercentage = false,
    bool isProfit = true,
  }) {
    final formatter = NumberFormat('#,###');
    String valueText;
    
    if (isPercentage) {
      valueText = '${value.toStringAsFixed(2)}%';
    } else {
      valueText = '¥${formatter.format(value)}';
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          valueText,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: value != 0 ? (isProfit ? Colors.green : Colors.red) : null,
          ),
        ),
      ],
    );
  }
  
  Widget _buildInvestmentCard(
    BuildContext context, 
    NisaViewModel viewModel, 
    NisaInvestment investment,
  ) {
    // 利益率の計算
    final investedAmount = investment.initialAmount;
    final profit = investment.currentValue - investedAmount;
    final profitRate = investedAmount > 0 
        ? (profit / investedAmount) * 100 
        : 0.0;
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    investment.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showEditInvestmentDialog(
                        context, 
                        viewModel, 
                        investment,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _showDeleteConfirmationDialog(
                        context, 
                        viewModel, 
                        investment,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('初期投資額'),
                Text(
                  '¥${NumberFormat('#,###').format(investment.initialAmount)}',
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('月々の拠出額'),
                Text(
                  '¥${NumberFormat('#,###').format(investment.monthlyContribution)}',
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('現在の評価額'),
                Text(
                  '¥${NumberFormat('#,###').format(investment.currentValue)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('利益率'),
                Text(
                  '${profitRate.toStringAsFixed(2)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: profitRate >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '毎月${investment.contributionDay}日に拠出',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '最終更新: ${DateFormat('yyyy/MM/dd').format(investment.lastUpdated)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _showAddInvestmentDialog(BuildContext context, NisaViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('NISA投資を追加'),
          content: SingleChildScrollView(
            child: NisaInvestmentForm(
              onSave: (investment) {
                viewModel.addInvestment(investment);
              },
            ),
          ),
        );
      },
    );
  }
  
  void _showEditInvestmentDialog(
    BuildContext context, 
    NisaViewModel viewModel, 
    NisaInvestment investment,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('NISA投資を編集'),
          content: SingleChildScrollView(
            child: NisaInvestmentForm(
              investment: investment,
              onSave: (updatedInvestment) {
                viewModel.updateInvestment(updatedInvestment);
              },
            ),
          ),
        );
      },
    );
  }
  
  void _showDeleteConfirmationDialog(
    BuildContext context, 
    NisaViewModel viewModel, 
    NisaInvestment investment,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('確認'),
          content: const Text('この投資データを削除してもよろしいですか？'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (investment.id != null) {
                  viewModel.deleteInvestment(investment.id!);
                }
              },
              child: const Text('削除'),
            ),
          ],
        );
      },
    );
  }
}
