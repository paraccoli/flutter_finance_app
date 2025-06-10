# 💰 MoneyG Finance App

<div align="center">
  <img src="assets/icon/app_icon.png" alt="MoneyG Finance App Logo" width="120" height="120">
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.24.5+-02569B?style=flat&logo=flutter&logoColor=white)](https://flutter.dev)
  [![Dart](https://img.shields.io/badge/Dart-3.5.4+-0175C2?style=flat&logo=dart&logoColor=white)](https://dart.dev)
  [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
  [![Android](https://img.shields.io/badge/Android-API%2021+-3DDC84?style=flat&logo=android&logoColor=white)](https://android.com)
  [![Version](https://img.shields.io/badge/Version-1.2.2-blue.svg)](https://github.com/yourusername/flutter_finance_app/releases)
  [![Security](https://img.shields.io/badge/Security-A%2B-green.svg)](./SECURITY.md)
</div>

## 📱 概要

**MoneyG Finance App**は、**プライバシーファースト**を理念とした個人財務管理アプリです。**完全ローカル保存**により、あなたの金融データが外部に送信されることは一切ありません。美しいUI/UXと強力な分析機能で、安心・安全な家計管理を実現します。

### 🔒 プライバシーファースト設計

- **🏠 完全ローカル**: データは一切インターネットに送信されません
- **🔐 エンドツーエンド暗号化**: デバイス内でのみ暗号化・復号化
- **🛡️ ゼロトラストネットワーク**: ネットワーク攻撃から完全保護
- **👤 データ主権**: あなたが完全にデータを管理

## ✨ 主な特徴

| 特徴 | 説明 |
|:---:|:---|
| 🎨 **Material Design 3** | 最新のGoogleデザインシステム採用 |
| 📊 **リアルタイム分析** | 高度な財務レポートと可視化 |
| 💾 **完全ローカル保存** | データ外部送信なしの安全設計 |
| 🔄 **CSVインポート/エクスポート** | 他の家計簿からの簡単移行 |
| 📱 **クロスプラットフォーム** | Android/iOS/Windows/macOS/Linux対応 |
| 🎯 **スワイプ操作** | 直感的な編集・削除操作 |

## 🚀 機能一覧

### 💰 基本的な財務管理

#### 📝 支出・収入記録
- **カテゴリ別管理**: 食費、交通費、光熱費、娯楽、医療費など
- **詳細記録**: 金額、日付、メモ、カテゴリを含む包括的記録
- **クイック入力**: 頻繁な支出の素早い記録
- **スワイプ操作**: 左右スワイプで編集・削除（NEW!）
- **確認ダイアログ**: 削除時の確認機能で誤操作防止

#### 📤 CSVインポート/エクスポート（NEW!）
- **一括インポート**: 既存の家計簿データをCSV形式で一括取込
- **データ移行**: 他のアプリからの簡単移行
- **エラーハンドリング**: インポート時の詳細エラー表示
- **エクスポート**: 期間・カテゴリ別のCSV出力
- **バックアップ**: 手動でのデータバックアップ
- **サンプルCSV**: テンプレートファイルで簡単データ準備

### 📊 分析・レポート機能

#### 📈 月別レポート
- **収支比較棒グラフ**: カテゴリ別の収入・支出を並べて表示（NEW!）
- **データ自動検出**: 実際のデータがある月を自動で初期表示（NEW!）
- **詳細分析**: 月間収支サマリーと傾向分析
- **UI改善**: 従来の円グラフから見やすい棒グラフに変更

#### 📉 資産分析
- **トレンド分析**: 収支推移の時系列グラフ
- **カテゴリ分析**: 支出パターンの詳細分析
- **年間パフォーマンス**: 長期的な財務状況の把握

### 💹 投資管理（NISA）

#### 📊 NISA投資記録
- **銘柄別管理**: 個別銘柄の投資額・評価額管理
- **パフォーマンス分析**: リアルタイム損益計算
- **将来予測**: 積立シミュレーション機能

### 🎯 予算・目標管理

#### 💡 予算設定
- **カテゴリ別予算**: 月間予算の詳細設定
- **使用状況表示**: リアルタイム予算進捗表示（NEW!）
- **アラート機能**: 予算超過時の通知
- **リアルタイム更新**: 支出記録と連動した即座の反映（NEW!）
- **設定統合**: 予算とアラート設定の一元管理（NEW!）

#### 📈 予算使用状況
- **詳細レポート**: カテゴリ別使用状況の可視化
- **進捗管理**: 予算達成率の追跡

## 🛠️ 技術選定

### フレームワーク・言語
- **Flutter 3.8.1+** - クロスプラットフォーム開発
- **Dart 3.8.1+** - アプリケーション言語

### 状態管理・アーキテクチャ
- **Provider** - 軽量で効率的な状態管理
- **MVVM パターン** - 保守性の高いアーキテクチャ

### データベース・ストレージ
- **SQLite** (`sqflite`) - ローカルデータベース
- **sqflite_common_ffi** - デスクトップ対応
- **SharedPreferences** - 設定データ保存

### UI・UX
- **Material Design 3** - 最新のGoogleデザインシステム
- **Google Fonts** - 美しいタイポグラフィ
- **FL Chart** - インタラクティブなグラフ表示

### 機能拡張
- **flutter_local_notifications** - ローカル通知（最新API対応）
- **file_picker** - CSVファイル選択
- **url_launcher** - 外部リンク起動
- **package_info_plus** - アプリ情報取得
- **share_plus** - ネイティブ共有機能
- **csv** - CSVファイル生成・解析
- **intl** - 国際化・日付フォーマット

## 📁 ファイル構成

```
lib/
├── main.dart                    # アプリエントリーポイント
├── models/                      # データモデル
│   ├── expense.dart            # 支出データモデル
│   ├── income.dart             # 収入データモデル
│   └── nisa_investment.dart    # NISA投資データモデル
├── services/                    # ビジネスロジック・サービス
│   ├── database_service.dart   # データベース操作
│   ├── notification_service.dart # 通知サービス
│   ├── export_service.dart     # データエクスポート
│   ├── import_service.dart     # CSVインポート（NEW!）
│   ├── budget_service.dart     # 予算管理（NEW!）
│   └── alert_settings_service.dart # アラート設定（NEW!）
├── viewmodels/                  # MVVM ViewModel
│   └── theme_viewmodel.dart    # テーマ状態管理
├── views/                       # 画面・UI
│   ├── home_screen.dart        # ホーム画面
│   ├── expense_screen.dart     # 支出記録画面
│   ├── income_screen.dart      # 収入記録画面
│   ├── monthly_report_screen.dart # 月次レポート
│   ├── asset_analysis_screen.dart # 資産分析
│   ├── nisa_screen.dart        # NISA管理画面
│   ├── setting_screen.dart     # 設定画面
│   ├── help_screen.dart        # ヘルプ画面
│   ├── budget_setting_screen.dart # 予算設定
│   ├── budget_usage_screen.dart   # 予算使用状況（NEW!）
│   ├── csv_import_screen.dart     # CSVインポート画面（NEW!）
│   ├── csv_export_screen.dart     # CSVエクスポート画面（NEW!）
│   ├── expense_search_screen.dart # 検索画面
│   └── splash_screen.dart      # スプラッシュ画面
├── widgets/                     # 再利用可能なウィジェット
│   ├── expense_form.dart       # 支出入力フォーム
│   ├── income_form.dart        # 収入入力フォーム
│   ├── expense_pie_chart.dart  # 支出円グラフ
│   ├── expense_bar_chart.dart  # 支出棒グラフ
│   ├── quick_expense_widget.dart # クイック支出
│   ├── quick_income_widget.dart  # クイック収入
│   ├── nisa_investment_form.dart # NISA投資フォーム
│   ├── nisa_performance_chart.dart # NISA運用グラフ
│   ├── nisa_forecast_chart.dart   # NISA予測グラフ
│   ├── nisa_asset_allocation_chart.dart # 資産配分
│   └── nisa_performance_analysis.dart # 運用分析
└── utils/                       # ユーティリティ
    └── (共通機能・ヘルパー関数)
```

## 🚀 導入方法

### 前提条件
- **Flutter SDK 3.24.5以上**
- **Dart SDK 3.5.4以上** 
- **Android Studio** または **VS Code**（推奨）
- **Android SDK** (Android開発の場合)
- **Xcode** (iOS開発の場合)

### インストール手順

1. **リポジトリのクローン**
   ```bash
   git clone https://github.com/paraccoli/flutter_finance_app.git
   cd flutter_finance_app
   ```

2. **依存関係のインストール**
   ```bash
   flutter pub get
   ```

3. **アプリアイコンの生成**
   ```bash
   flutter pub run flutter_launcher_icons:main
   ```

4. **アプリの実行**
   ```bash
   # デバッグモード
   flutter run
   
   # リリースビルド (Android)
   flutter build apk --release
   
   # リリースビルド (iOS)
   flutter build ios --release
   ```

## ⚙️ 設定方法

### Android設定
`android/app/build.gradle`で最小SDKを確認：
```gradle
minSdkVersion 21
targetSdkVersion 34
```

### iOS設定 (将来対応予定)
`ios/Runner/Info.plist`での設定が必要になります。

### 通知設定
アプリ初回起動時に通知権限の許可が求められます。
設定画面から通知のON/OFFと時刻を変更できます。

## 🔧 開発・ビルド

### 開発環境での実行
```bash
# ホットリロード付きで実行
flutter run

# 特定のデバイスで実行
flutter run -d <device_id>

# デバイス一覧確認
flutter devices
```

### コード解析・テスト
```bash
# コード解析
flutter analyze

# テスト実行
flutter test

# テストカバレッジ
flutter test --coverage
```

### ビルド
```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS (macOS必須)
flutter build ios --release

# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

## 🤝 貢献方法

1. このリポジトリをフォーク
2. フィーチャーブランチを作成 (`git checkout -b feature/AmazingFeature`)
3. 変更をコミット (`git commit -m 'Add some AmazingFeature'`)
4. ブランチにプッシュ (`git push origin feature/AmazingFeature`)
5. プルリクエストを開く

### 開発ガイドライン
- **コードスタイル**: `flutter_lints`に準拠
- **コミットメッセージ**: わかりやすい日本語で記述
- **テスト**: 新機能には適切なテストを追加
- **ドキュメント**: 重要な変更はREADMEも更新

## 📱 スクリーンショット・デモ

*アプリのスクリーンショットや動画デモは今後追加予定です*

## 🐛 既知の問題・制限事項

- iOS版は現在開発中です
- 一部のデスクトップ環境では通知機能に制限があります
- 大量データ（10,000件以上）でのパフォーマンス最適化が必要な場合があります
- CSVインポート時は適切なフォーマットが必要です（サンプルCSV参照）

## 📞 サポート・お問い合わせ

- **GitHub Issues**: [Issues ページ](https://github.com/paraccoli/flutter_finance_app/issues)
- **セキュリティ**: セキュリティに関する問題は [SECURITY.md](SECURITY.md) を参照
- **プライバシーポリシー**: [PRIVACY.md](PRIVACY.md)
- **貢献ガイド**: [CONTRIBUTING.md](CONTRIBUTING.md)

## 📝 更新履歴

### バージョン 1.2.2 (2025-06-10) 🆕
- 🔧 **fl_chart 1.0.0対応**: 最新版ライブラリへの完全移行
- 🔔 **通知API更新**: 非推奨APIの削除と最新API採用
- 📊 **月別レポート改善**: 円グラフから見やすい棒グラフに変更
- 📅 **自動月選択**: データがある月を自動で初期表示
- 👆 **スワイプ操作**: 収入・支出リストで編集・削除操作
- ⚠️ **削除確認**: 誤削除防止の確認ダイアログ追加
- 💰 **予算リアルタイム更新**: 支出記録と連動した即座の反映
- 🔧 **設定画面統合**: 予算アラートを予算設定に統合
- 📥 **CSV機能拡張**: インポート・エクスポート機能の全面改良
- 🛡️ **セキュリティ強化**: SECURITY.mdとプライバシー保護の明文化

### バージョン 1.1.0 (2025-06-08)
- 🎉 iOS機能の削除とMaterial Design統一
- ✨ 検索・フィルター機能の追加
- 💾 バックアップ・復元機能の実装
- 🎯 予算管理機能の追加
- 📊 クイック収入・支出機能の追加
- 🗑️ データ完全削除機能の追加
- 📱 SafeArea対応とUI改善
- 🔧 各種設定機能の拡充

### バージョン 1.0.0 (初回リリース)
- 📊 基本的な支出・収入記録機能
- 💹 NISA投資管理機能
- 📈 月次レポート・資産分析
- 🔔 通知機能
- ⚙️ 基本設定機能

## 📄 ライセンス

このプロジェクトは [MIT License](LICENSE) の下で配布されています。

詳細については [LICENSE](LICENSE) ファイルをご覧ください。

---

<div align="center">
  <p>❤️ Made with Flutter by <a href="https://github.com/paraccoli">Paraccoli</a></p>
  <p>🌟 このプロジェクトが役に立ったら、ぜひスターをお願いします！</p>
  <p>🔒 プライバシーファースト・完全ローカル保存で安心・安全な家計管理</p>
</div>
