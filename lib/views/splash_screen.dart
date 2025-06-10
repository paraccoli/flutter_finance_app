import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'home_screen.dart';
import '../services/database_service.dart';
import '../viewmodels/expense_viewmodel.dart';
import '../viewmodels/income_viewmodel.dart';
import '../viewmodels/nisa_viewmodel.dart';
import '../viewmodels/asset_analysis_viewmodel.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  @override
  void initState() {
    super.initState();
    
    // アニメーションコントローラーの初期化
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // フェードインアニメーション
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeInOut),
    ));

    // スケールアニメーション
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
    ));

    // アニメーション開始
    _animationController.forward();

    // 初期化とホーム画面遷移
    _initializeAndNavigate();

    if (kDebugMode) {
      debugPrint('スプラッシュスクリーン初期化完了');
    }
  }

  Future<void> _initializeAndNavigate() async {
    try {
      // データベース初期化
      await _initializeDatabase();
      
      // プロバイダーのリセット
      await _resetProviders();
      
      // 最低3秒間スプラッシュ画面を表示
      await Future.delayed(const Duration(seconds: 3));
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('初期化エラー: $e');
      }
      
      // エラーが発生してもホーム画面に遷移
      await Future.delayed(const Duration(seconds: 3));
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    }
  }

  Future<void> _initializeDatabase() async {
    try {
      final db = await DatabaseService().database;
      if (kDebugMode) {
        debugPrint('データベース再初期化完了: ${db.path}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('データベース初期化エラー: $e');
      }
    }
  }

  Future<void> _resetProviders() async {
    if (mounted) {
      try {
        // プロバイダーのデータをリセット
        final expenseViewModel = Provider.of<ExpenseViewModel>(context, listen: false);
        final incomeViewModel = Provider.of<IncomeViewModel>(context, listen: false);
        final nisaViewModel = Provider.of<NisaViewModel>(context, listen: false);
        final assetAnalysisViewModel = Provider.of<AssetAnalysisViewModel>(context, listen: false);
        
        await expenseViewModel.loadExpenses();
        await incomeViewModel.loadIncomes();
        await nisaViewModel.loadInvestments();
        await assetAnalysisViewModel.loadData();
        
        if (kDebugMode) {
          debugPrint('プロバイダーリセット完了');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('プロバイダーリセットエラー: $e');
        }
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // アプリアイコン
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            offset: const Offset(0, 8),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/icon/app_icon.png',
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            if (kDebugMode) {
                              debugPrint('アプリアイコンの読み込みエラー: $error');
                            }
                            // アイコンが読み込めない場合のフォールバック
                            return Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet,
                                size: 60,
                                color: Colors.green,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // アプリタイトル
                    Text(
                      'Money:G',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2.0,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // サブタイトル
                    Text(
                      '家計管理アプリ',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.9),
                        letterSpacing: 1.0,
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // ローディングインジケーター
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // ローディングテキスト
                    Text(
                      'Loading...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.7),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
