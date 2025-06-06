import 'package:flutter/foundation.dart';
import '../models/nisa_investment.dart';
import '../services/database_service.dart';

class NisaViewModel extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<NisaInvestment> _investments = [];

  // ゲッター
  List<NisaInvestment> get investments => _investments;

  // 初期化
  Future<void> loadInvestments() async {
    _investments = await _databaseService.getNisaInvestments();
    notifyListeners();
  }

  // 投資の追加
  Future<void> addInvestment(NisaInvestment investment) async {
    await _databaseService.insertNisaInvestment(investment);
    await loadInvestments();
  }

  // 投資の更新
  Future<void> updateInvestment(NisaInvestment investment) async {
    await _databaseService.updateNisaInvestment(investment);
    await loadInvestments();
  }

  // 投資の削除
  Future<void> deleteInvestment(int id) async {
    await _databaseService.deleteNisaInvestment(id);
    await loadInvestments();
  }

  // 合計投資額を計算
  double getTotalInvestedAmount() {
    double total = 0;
    for (var investment in _investments) {
      total += investment.initialAmount;
      
      // 開始日から現在までの月数を計算
      DateTime now = DateTime.now();
      int monthsSinceStart = (now.year - investment.lastUpdated.year) * 12 + 
                            now.month - investment.lastUpdated.month;
      
      // 毎月の積立額を合計に加算
      total += investment.monthlyContribution * monthsSinceStart;
    }
    return total;
  }

  // 合計評価額を計算
  double getTotalCurrentValue() {
    return _investments.fold(0, (sum, investment) => sum + investment.currentValue);
  }

  // 評価損益を計算
  double getTotalProfit() {
    return getTotalCurrentValue() - getTotalInvestedAmount();
  }
}
