# 開発者向け設定ガイド

## AdMob設定

### テスト環境
- インタースティシャル広告ID: `ca-app-pub-3940256099942544/1033173712`
- バナー広告ID: `ca-app-pub-3940256099942544/6300978111`
- AdMobアプリケーションID: `ca-app-pub-3940256099942544~3347511713`

### 本番環境設定手順
1. `lib/services/admob_service.dart`の本番用広告IDを更新
2. `android/app/src/main/AndroidManifest.xml`のAdMobアプリケーションIDを更新
3. Google Play Consoleでアプリを登録
4. AdMobでアプリと広告ユニットを作成

## アプリ内課金設定

### Google Play Console設定
1. アプリ内商品の作成
   - 商品ID: `premium_monthly`
   - 価格: ¥200/月
   - 商品タイプ: サブスクリプション

2. 課金テスト
   - Google Play Console > 設定 > ライセンステスト
   - テストアカウントを追加

### 重要なファイル
- `lib/services/purchase_service.dart` - アプリ内課金ロジック
- `android/app/build.gradle` - 署名設定

## データベース設計

### テーブル構造
- `expenses` - 支出データ
- `incomes` - 収入データ
- `nisa_investments` - NISA投資データ
- `custom_categories` - カスタムカテゴリ

### マイグレーション
- `database_service.dart`でバージョン管理
- 新テーブル追加時はバージョン番号を更新

## ビルド設定

### Android
```bash
# デバッグビルド
flutter build apk --debug

# リリースビルド
flutter build apk --release

# App Bundle（Google Play用）
flutter build appbundle --release
```

### 署名設定
1. `android/key.properties`作成（.gitignoreに含まれる）
2. リリース用キーストアの生成
3. `android/app/build.gradle`で署名設定

## 環境変数

### .env ファイル（.gitignoreに含まれる）
```
ADMOB_APP_ID=your_production_admob_app_id
ADMOB_INTERSTITIAL_ID=your_production_interstitial_id
ADMOB_BANNER_ID=your_production_banner_id
```

## セキュリティ

### 機密情報の管理
- 本番用APIキーはコミットしない
- `.gitignore`で適切にファイルを除外
- 環境変数や設定ファイルを使用

### 広告設定
- デバッグ時は必ずテスト広告IDを使用
- 本番時のみ実際の広告IDに切り替え

## デプロイメント

### Google Play Console
1. アプリバンドルのアップロード
2. ストアリスティングの更新
3. リリーストラックの設定（内部テスト → アルファ → ベータ → 本番）

### GitHub
1. タグ付きリリースの作成
2. リリースノートの更新
3. APKファイルの添付
