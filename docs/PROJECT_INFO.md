# Money:G プロジェクト情報

## プロジェクト概要
- **アプリ名**: Money:G - 個人財務管理アプリ
- **バージョン**: 1.4.0（広告システム統合版）
- **開発者**: paraccoli
- **リポジトリ**: https://github.com/paraccoli/flutter_finance_app

## 技術スタック
- **Framework**: Flutter 3.8.1+
- **Language**: Dart 3.8.1+
- **Database**: SQLite (sqflite)
- **State Management**: Provider (MVVM)
- **Ads**: Google Mobile Ads SDK 5.3.1
- **IAP**: In-App Purchase 3.2.3

## 重要なバージョン情報
```yaml
flutter: 3.8.1
dart: 3.8.1
google_mobile_ads: ^5.3.1
in_app_purchase: ^3.2.3
sqflite: ^2.4.1
provider: ^6.1.2
```

## アプリパッケージ情報
- **Package Name**: com.moneyg.finance_app
- **Application ID**: com.moneyg.finance_app
- **Min SDK**: 21 (Android 5.0)
- **Target SDK**: 34 (Android 14)

## 広告設定
### テスト環境（開発用）
- AdMob App ID: ca-app-pub-3940256099942544~3347511713
- Interstitial Ad ID: ca-app-pub-3940256099942544/1033173712
- Banner Ad ID: ca-app-pub-3940256099942544/6300978111

### 広告表示間隔
- 起動時: アプリ起動毎
- 定期表示: 30分間隔（デバッグ時は3分間隔）
- バナー: 常時表示（画面下部）

## プレミアム版設定
- **商品ID**: premium_monthly
- **価格**: 月額200円
- **機能**: 全広告非表示

## ビルド情報
### バージョン管理
```yaml
# pubspec.yaml
version: 1.4.0+4
```

### 署名設定
- リリース用キーストア: upload-keystore.jks
- キー設定: android/key.properties（.gitignoreに含む）

## データベース
### バージョン
- Current: 4
- Tables: expenses, incomes, nisa_investments, custom_categories

### マイグレーション履歴
- v1: 基本テーブル作成
- v2: NISA投資テーブル追加
- v3: カスタムカテゴリテーブル追加
- v4: 広告・課金対応

## 開発環境
- **IDE**: VS Code / Android Studio
- **Platform**: Windows 11
- **Test Device**: moto g52j 5G (Android)

## リリース履歴
- v1.0.0: 初回リリース
- v1.1.0: 検索・予算機能追加
- v1.2.2: CSV、スワイプ、UI改善
- v1.3.1: カスタムカテゴリ機能
- v1.3.2: レガシーCSVサポート
- v1.4.0: 広告システム・プレミアム版統合

## 重要なファイル
### 設定ファイル
- `pubspec.yaml` - 依存関係
- `android/app/build.gradle` - Android設定
- `android/app/src/main/AndroidManifest.xml` - 権限・設定

### 広告関連
- `lib/services/admob_service.dart` - 広告管理
- `lib/services/purchase_service.dart` - アプリ内課金
- `lib/widgets/ad_banner_widget.dart` - 広告UI

### データベース
- `lib/services/database_service.dart` - DB管理
- `lib/models/` - データモデル

### UI/UX
- `lib/views/` - 画面
- `lib/widgets/` - 再利用可能コンポーネント
- `lib/viewmodels/` - 状態管理

## セキュリティ
### 保護対象
- 本番用AdMob ID
- Google Play署名キー
- アプリ内課金設定
- ユーザーデータベース

### .gitignore設定
- android/key.properties
- *.jks / *.keystore
- .env ファイル
- 本番用設定ファイル

## 連絡先
- **GitHub**: @paraccoli
- **Twitter**: @paraccoli
- **Email**: [GitHub Profile参照]
