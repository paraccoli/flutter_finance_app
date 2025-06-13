# MoneyG v1.2.3 詳細リリースノート

## 📊 リリース概要

| 項目 | 詳細 |
|------|------|
| **バージョン** | 1.2.3+4 |
| **リリース日** | 2025年6月14日 |
| **リリースタイプ** | メンテナンス・コード品質向上 |
| **APKサイズ** | 27.5MB |
| **ZIP圧縮後** | 27.2MB |

## 🔍 問題の詳細

### 発生していた警告
```bash
PS D:\flutter\flutter_finance_app> flutter analyze
Analyzing flutter_finance_app...

info - 'Share' is deprecated and shouldn't be used. Use SharePlus instead - lib\services\export_service.dart:49:13 - deprecated_member_use
info - 'shareXFiles' is deprecated and shouldn't be used. Use SharePlus.instance.share() instead - lib\services\export_service.dart:49:19 - deprecated_member_use
info - 'Share' is deprecated and shouldn't be used. Use SharePlus instead - lib\services\export_service.dart:98:13 - deprecated_member_use
info - 'shareXFiles' is deprecated and shouldn't be used. Use SharePlus.instance.share() instead - lib\services\export_service.dart:98:19 - deprecated_member_use
info - 'Share' is deprecated and shouldn't be used. Use SharePlus instead - lib\services\export_service.dart:172:13 - deprecated_member_use
info - 'shareXFiles' is deprecated and shouldn't be used. Use SharePlus.instance.share() instead - lib\services\export_service.dart:172:19 - deprecated_member_use

6 issues found. (ran in 2.2s)
```

## 🛠️ 修正の詳細

### 修正されたメソッド

#### 1. exportExpensesToCsv() - 行49
**修正前:**
```dart
await Share.shareXFiles([XFile(file.path)]);
```
**修正後:**
```dart
await SharePlus.instance.share(ShareParams(
  files: [XFile(file.path)],
));
```

#### 2. exportIncomesToCsv() - 行98  
**修正前:**
```dart
await Share.shareXFiles([XFile(file.path)]);
```
**修正後:**
```dart
await SharePlus.instance.share(ShareParams(
  files: [XFile(file.path)],
));
```

#### 3. exportAllDataToCsv() - 行172
**修正前:**
```dart
await Share.shareXFiles([XFile(file.path)]);
```
**修正後:**
```dart
await SharePlus.instance.share(ShareParams(
  files: [XFile(file.path)],
));
```

## 🔧 技術的な変更点

### APIの移行
- **旧API**: `Share.shareXFiles()` - share_plusパッケージの非推奨メソッド
- **新API**: `SharePlus.instance.share()` - 推奨される新しいメソッド
- **パラメータ**: `ShareParams`オブジェクトを使用してファイル共有を実装

### パッケージ情報
- **share_plus**: ^11.0.0
- **cross_file**: XFileクラスを使用してファイル操作を維持

### 影響を受けるプラットフォーム
- **Android**: ✅ 修正済み
- **iOS**: ✅ 修正済み（release/iosディレクトリも対応）

## ✅ 品質保証

### 静的解析結果
```bash
PS D:\flutter\test\flutter_finance_app> flutter analyze
Analyzing flutter_finance_app...
No issues found! (ran in 5.8s)
```

### ビルド結果
```bash
Running Gradle task 'assembleRelease'...
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 11792 bytes (99.3% reduction).
√ Built build\app\outputs\flutter-apk\app-release.apk (26.2MB)
```

### 機能テスト
- ✅ CSVエクスポート機能の動作確認
- ✅ ファイル共有機能の動作確認
- ✅ UI操作に影響なし

## 📁 修正されたファイル

### メインアプリ
- `lib/services/export_service.dart`
  - 行49: exportExpensesToCsv() 
  - 行98: exportIncomesToCsv()
  - 行172: exportAllDataToCsv()

### iOS リリース版
- `release/ios/lib/services/export_service.dart`
  - 同じ3箇所を修正

## 🎯 今後の展望

### コード品質
- 非推奨API使用の完全排除
- 静的解析警告0件の維持
- Flutter/Dartのベストプラクティス準拠

### 互換性
- 将来のshare_plusパッケージアップデートに対応
- Flutter SDKアップデートへの準備

## 📋 リリースチェックリスト

- ✅ 全ての非推奨API警告を修正
- ✅ `flutter analyze`でエラー0件確認
- ✅ APKビルド成功確認
- ✅ ファイルサイズ確認
- ✅ リリースノート作成
- ✅ GitHub用リリース文章作成
- ✅ バージョン番号更新 (1.2.2+3 → 1.2.3+4)

---

**開発者向け情報**: このリリースは主にコードの保守性と将来的な互換性向上を目的としています。エンドユーザーへの機能変更はありませんが、アプリの長期的な安定性が向上しています。
