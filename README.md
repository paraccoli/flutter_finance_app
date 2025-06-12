# Money:G - 個人財務管理アプリ

<div align="center">
  <img src="assets/icon/app_icon.png" alt="Money:G Logo" width="120" height="120">
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.32.2+-02569B?style=flat&logo=flutter&logoColor=white)](https://flutter.dev)
  [![Dart](https://img.shields.io/badge/Dart-3.8.1+-0175C2?style=flat&logo=dart&logoColor=white)](https://dart.dev)
  [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
  [![Android](https://img.shields.io/badge/Android-API%2021+-3DDC84?style=flat&logo=android&logoColor=white)](https://android.com)
  [![iOS](https://img.shields.io/badge/iOS-13.0+-000000?style=flat&logo=apple&logoColor=white)](https://www.apple.com/ios)
  [![Version](https://img.shields.io/badge/Version-1.2.2-blue.svg)](https://github.com/paraccoli/flutter_finance_app/releases)
</div>

## 📱 アプリ概要

**Money:G**は、個人の財務管理を簡単かつ効率的に行うためのFlutterアプリです。支出・収入の記録から投資管理まで、包括的な資産管理機能を提供します。

**🍎 iOS版v1.2.2リリース**: [iOS版リリースノート](RELEASE_NOTES_iOS_v1.2.2.md)をご確認ください！

### ✨ 主な特徴

- 🎨 **Material Design**に基づいた美しく直感的なUI
- 📊 **リアルタイム分析**による詳細な財務レポート  
- 💾 **完全ローカル保存**によるプライバシー保護
- � **CSV インポート/エクスポート**でデータ移行が簡単
- 🔄 **スワイプアクション**による直感的な編集・削除
- 📱 **クロスプラットフォーム**対応（Android/iOS対応済み）
- 🌟 **スプラッシュスクリーン**で洗練された起動体験

## 🚀 全機能一覧

### 💰 基本的な財務管理
- **支出記録**
  - カテゴリ別分類（食費、交通費、光熱費、家賃、娯楽、医療費、その他）
  - 金額、日付、メモの記録
  - クイック支出登録
- **収入記録**
  - カテゴリ別分類（給与、副業、投資、その他）
  - 金額、日付、メモの記録
  - クイック収入登録

### 📊 分析・レポート機能
- **月次レポート**
  - 支出内訳の棒グラフ表示（v1.2.2で円グラフから改善）
  - カテゴリ別支出ランキング
  - 月間収支サマリー
  - 自動的に最新データ月を選択表示
- **資産分析**
  - 収支トレンドの時系列グラフ
  - 貯蓄推移の可視化
  - 年間財務パフォーマンス分析

### 💹 投資管理（NISA）
- **NISA投資記録**
  - 銘柄別投資額管理
  - リアルタイム損益計算
  - 月次積立設定
- **投資分析**
  - ポートフォリオ分散度表示
  - 運用パフォーマンス分析
  - 将来予測シミュレーション

### 🔍 データ管理・検索
- **高度な検索・フィルター**
  - 期間指定検索
  - カテゴリ別フィルタリング
  - 金額範囲指定
- **CSV インポート/エクスポート**（v1.2.2新機能）
  - CSV形式でのデータ入出力
  - 期間別・カテゴリ別エクスポート
  - 他アプリからのデータ移行対応
  - エラーハンドリングと検証機能
- **スワイプアクション**（v1.2.2新機能）
  - 収入・支出リストでのスワイプ編集
  - スワイプ削除（確認ダイアログ付き）
  - 直感的なデータ操作

### 💾 バックアップ・復元
- **完全バックアップ**
  - 全データのJSON形式エクスポート
  - 自動タイムスタンプ付きファイル名
  - メタデータと統計情報を含む包括的バックアップ
- **安全な復元**
  - 複数段階確認による誤操作防止
  - バックアップファイル情報の詳細表示
  - 復元前のデータ完全性チェック

### 🎯 予算・目標管理
- **リアルタイム予算管理**（v1.2.2で大幅改善）
  - カテゴリ別月間予算設定
  - リアルタイム予算使用率の可視化
  - 即座に反映される予算超過アラート
  - 予算設定の即時更新・反映
- **目標設定**
  - 貯蓄目標の設定・追跡
  - 達成率の進捗表示

### 🔔 通知・リマインダー
- **スマート通知**
  - 記録忘れ防止リマインダー
  - 予算超過アラート
  - 定期支出・収入の通知

### ⚙️ カスタマイズ・設定
- **外観設定**
  - ダークモード切り替え
  - Material Designテーマ
  - スプラッシュスクリーン（v1.2.2新機能）
- **データ管理**
  - 完全データ削除機能
  - CSV インポート/エクスポート機能
  - 統計情報の表示
- **アプリ情報**
  - バージョン情報
  - 開発者リンク（GitHub/X）
  - ヘルプ・FAQ

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
- **flutter_local_notifications** - ローカル通知（v1.2.2で改善）
- **url_launcher** - 外部リンク起動
- **package_info_plus** - アプリ情報取得
- **share_plus** - ネイティブ共有機能（v1.2.2でiOS対応）
- **csv** - CSVファイル生成・読み取り（v1.2.2で強化）
- **file_picker** - CSVファイル選択（v1.2.2新機能）
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
│   ├── notification_service.dart # 通知サービス（v1.2.2改善）
│   ├── export_service.dart     # CSV エクスポート/インポート（v1.2.2強化）
│   ├── budget_service.dart     # 予算管理（v1.2.2新規）
│   └── alert_settings_service.dart # アラート設定（v1.2.2新規）
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
│   ├── budget_setting_screen.dart # 予算設定（v1.2.2改善）
│   ├── budget_usage_screen.dart   # 予算使用状況（v1.2.2新規）
│   ├── csv_import_screen.dart     # CSV インポート（v1.2.2新規）
│   ├── csv_export_screen.dart     # CSV エクスポート（v1.2.2新規）
│   ├── expense_search_screen.dart # 検索画面
│   └── splash_screen.dart      # スプラッシュ画面（v1.2.2新規）
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
- **Flutter SDK 3.8.1以上**
- **Dart SDK 3.8.1以上** 
- **Android Studio** または **VS Code**（推奨）
- **Android SDK** (Android開発の場合)
- **Xcode** (iOS開発の場合)

### インストール手順

1. **リポジトリのクローン**
   ```bash
   git clone https://github.com/paraccoli/-Money-G-Finance-app.git
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

### iOS設定（v1.2.2対応済み）
詳細なiOS設定については [iOS版インストールガイド](release/ios/INSTALL_iOS.md) をご確認ください。
`ios/Runner/Info.plist`に必要な権限設定が含まれています：
- ファイルアクセス権限（CSV機能用）
- 通知権限
- ユーザーインターフェース設定

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

現在、既知の重大な問題はありません。v1.2.2で主要なバグが修正されました：
- ✅ 予算設定が即座に反映されない問題を修正
- ✅ 通知API の非推奨警告を解決
- ✅ iOS版の安定性向上
- 一部のデスクトップ環境では通知機能に制限があります

## � ダウンロード

### 🎯 最新リリース: v1.2.2

#### 🤖 Android版
- **APK**: [MoneyG-Android-v1.2.2.apk](https://github.com/paraccoli/flutter_finance_app/releases/download/v1.2.2/MoneyG-Android-v1.2.2.apk)
- **要件**: Android 5.0 (API 21) 以上

#### 🍎 iOS版
- **ソースコード**: [MoneyG-iOS-v1.2.2.zip](https://github.com/paraccoli/flutter_finance_app/releases/download/v1.2.2/MoneyG-iOS-v1.2.2.zip)
- **要件**: iOS 13.0 以上
- **インストール**: [iOS版インストールガイド](release/ios/INSTALL_iOS.md)

#### 📋 全リリース
すべてのリリースは [GitHub Releases](https://github.com/paraccoli/flutter_finance_app/releases) で確認できます。

---

## �📞 サポート・お問い合わせ

- **GitHub Issues**: [Issues ページ](https://github.com/paraccoli/flutter_finance_app/issues)
- **GitHub Discussions**: [コミュニティ](https://github.com/paraccoli/flutter_finance_app/discussions)
- **開発者Twitter**: [@paraccoli](https://twitter.com/paraccoli)
- **プライバシーポリシー**: [PRIVACY.md](PRIVACY.md)
- **セキュリティポリシー**: [SECURITY.md](SECURITY.md)
- **コントリビューションガイド**: [CONTRIBUTING.md](CONTRIBUTING.md)

## 📝 更新履歴

### バージョン 1.2.2 (2025-06-12) 🎉
**iOS版初回リリース & Android版重要更新**

#### 🍎 iOS版新機能
- ✨ iOS 13.0以上完全対応
- 📱 iOS専用UI最適化
- 🔔 iOS通知システム統合
- 📤 iOSネイティブ共有機能

#### 🆕 新機能（全プラットフォーム）
- ✨ **CSV インポート/エクスポート**: 他アプリからのデータ移行対応
- 🌟 **スプラッシュスクリーン**: アプリ起動体験の向上
- 👆 **スワイプアクション**: 収入・支出リストでのスワイプ編集・削除
- 📊 **月次レポート改善**: 円グラフから棒グラフに変更、自動月選択

#### 🔧 改善・修正
- 🐛 **予算設定リアルタイム反映**: 設定変更が即座に反映されるよう修正
- 🔔 **通知API更新**: 非推奨API使用の警告を解決
- 📈 **fl_chart 1.0.0**: 最新チャートライブラリに更新
- 🛡️ **セキュリティ強化**: ローカル保存のセキュリティ向上

#### 📚 ドキュメント
- 📖 **包括的ドキュメント**: README、CONTRIBUTING、SECURITY
- 🍎 **iOS専用ガイド**: インストール・機能・リリースノート
- 🎯 **GitHub Projects**: プロジェクト管理体系の構築

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
</div>
