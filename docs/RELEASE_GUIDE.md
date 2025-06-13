# 🚀 MoneyG Finance App - リリースガイド

> **MoneyG Finance App**の新バージョンリリース手順書

---

## 📋 リリース準備チェックリスト

### 🔍 事前確認

- [ ] すべてのPull Requestがマージ済み
- [ ] 既知の重大なバグがない
- [ ] CI/CDが正常に通過している
- [ ] 手動テストが完了している

### 📝 ドキュメント更新

- [ ] `CHANGELOG.md`の更新
- [ ] `README.md`のバージョン情報更新
- [ ] 新機能の説明追加
- [ ] 既知の問題・制限事項の更新

---

## 🏷️ バージョニング

### セマンティックバージョニング

MoneyG Finance Appは[セマンティックバージョニング](https://semver.org/)に従います：

- **MAJOR** (例: 2.0.0): 破壊的変更
- **MINOR** (例: 1.3.0): 新機能追加
- **PATCH** (例: 1.2.1): バグ修正

### バージョン決定基準

```
v1.2.2 → v1.2.3: バグ修正のみ
v1.2.2 → v1.3.0: 新機能追加
v1.2.2 → v2.0.0: 破壊的変更
```

---

## 🔧 リリース手順

### 1. バージョンアップ

#### pubspec.yamlの更新
```yaml
version: 1.3.0+10  # バージョン+ビルド番号
```

#### バージョンファイルの更新
```bash
# バージョン情報の一括更新
scripts/update_version.sh 1.3.0
```

### 2. ビルド・テスト

#### Android
```bash
# 開発版ビルド
flutter build apk --debug

# リリース版ビルド
flutter build apk --release
flutter build appbundle --release  # Google Play Store用
```

#### iOS
```bash
# 開発版ビルド
flutter build ios --debug

# リリース版ビルド
flutter build ios --release
flutter build ipa  # App Store用
```

### 3. 品質保証

#### 自動テスト
```bash
flutter analyze
flutter test
flutter test integration_test/
```

#### 手動テスト
- [ ] 主要機能の動作確認
- [ ] 新機能の動作確認
- [ ] 回帰テストの実施
- [ ] パフォーマンステスト

---

## 📦 パッケージング

### Android APK

```bash
# デバッグ版
flutter build apk --debug --target-platform android-arm64

# リリース版
flutter build apk --release --target-platform android-arm64

# ファイル名を変更
mv build/app/outputs/flutter-apk/app-release.apk \
   MoneyG-Android-v1.3.0.apk
```

### Android App Bundle

```bash
# Google Play Store用
flutter build appbundle --release

# ファイル名を変更
mv build/app/outputs/bundle/release/app-release.aab \
   MoneyG-Android-v1.3.0.aab
```

### iOS IPA

```bash
# App Store用
flutter build ipa --release

# TestFlight用
flutter build ipa --release --export-options-plist=ios/ExportOptions.plist
```

---

## 📄 リリースノート作成

### リリースノートの構成

1. **概要**: リリースの主要なポイント
2. **新機能**: 追加された機能
3. **改善**: 既存機能の改善
4. **バグ修正**: 修正されたバグ
5. **技術的変更**: 開発者向け情報
6. **既知の問題**: 未解決の問題

### テンプレート

```markdown
# 🚀 MoneyG Finance App v1.3.0

## ✨ 主要な変更

このリリースでは、ユーザー体験の向上と新機能の追加を行いました。

## 🆕 新機能

- **カテゴリカスタマイズ**: 独自のカテゴリ作成が可能
- **テーマ選択**: ダークモード・ライトモードの選択

## 🔧 改善

- 月次レポートの表示速度向上
- UI/UXの全体的な改善

## 🐛 バグ修正

- 予算設定の反映問題を修正
- データエクスポートの文字化け修正

## 📱 対応プラットフォーム

- Android 5.0 (API 21) 以上
- iOS 13.0 以上

## 📋 既知の問題

現在、既知の重大な問題はありません。

---

**ダウンロード**: [GitHub Releases](https://github.com/paraccoli/flutter_finance_app/releases/tag/v1.3.0)
```

---

## 🎯 プラットフォーム別リリース

### Android

#### Google Play Store
1. **Play Console**にログイン
2. **アプリ版本**セクションへ移動
3. **新しいリリース**を作成
4. AAAファイルをアップロード
5. リリースノートを記入
6. **審査のために送信**

#### GitHub Releases
1. GitHubのリリースページへ移動
2. **新しいリリース**を作成
3. タグ名: `v1.3.0`
4. APKファイルを添付
5. リリースノートを記載

### iOS

#### App Store Connect
1. **App Store Connect**にログイン
2. **My Apps**から対象アプリを選択
3. **新しいバージョン**を作成
4. IPAファイルをアップロード（Xcode経由）
5. **審査のために送信**

#### TestFlight
1. IPAファイルをTestFlightにアップロード
2. ベータテスターに配信
3. フィードバック収集

---

## 🔄 継続的インテグレーション

### GitHub Actions

```yaml
name: Release Build
on:
  push:
    tags:
      - 'v*'

jobs:
  build-android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-java@v3
      - uses: subosito/flutter-action@v2
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v3

  build-ios:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter build ios --release
```

---

## 📊 リリース後のモニタリング

### メトリクス監視

- **ダウンロード数**: プラットフォーム別統計
- **クラッシュレート**: 安定性指標
- **ユーザーレビュー**: フィードバック分析
- **アップデート率**: 新バージョン採用率

### 問題対応

- **クリティカルバグ**: 緊急ホットフィックス
- **一般的なバグ**: 次のパッチ版で修正
- **機能要望**: バックログに追加

---

## 🎯 ホットフィックス手順

緊急のバグ修正が必要な場合：

### 1. ホットフィックスブランチ作成

```bash
git checkout main
git pull origin main
git checkout -b hotfix/v1.2.3
```

### 2. 修正・テスト

```bash
# バグ修正
# テスト実行
flutter test
flutter analyze
```

### 3. 緊急リリース

```bash
# バージョン更新
# ビルド
flutter build apk --release
flutter build ipa --release

# リリース
```

---

## 📚 参考リソース

### 公式ドキュメント

- [Flutter Deployment](https://flutter.dev/docs/deployment)
- [Android App Signing](https://developer.android.com/studio/publish/app-signing)
- [iOS App Distribution](https://developer.apple.com/distribute/)

### ツール・サービス

- **GitHub Releases**: リリース管理
- **Google Play Console**: Android配信
- **App Store Connect**: iOS配信
- **Firebase**: 分析・モニタリング

---

**📝 最終更新**: 2025年6月12日  
**📄 バージョン**: v1.0  
**👥 対象**: 開発チーム・リリース担当者

> **注意**: リリース手順は慎重に実行し、各ステップで確認を行ってください。