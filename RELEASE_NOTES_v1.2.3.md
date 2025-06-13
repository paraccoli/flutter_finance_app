# MoneyG v1.2.3 リリースノート

**リリース日**: 2025年6月14日  
**バージョン**: 1.2.3+4

## 🔧 修正内容

### SharePlusパッケージの非推奨API修正
- **問題**: `flutter analyze`実行時に、share_plusパッケージの非推奨API（`Share.shareXFiles`）使用による警告が発生していました
- **修正**: 新しいAPI（`SharePlus.instance.share`）への移行を完了
- **影響**: CSVエクスポート機能における警告が解消され、将来的な互換性が向上

### 📁 修正対象ファイル
- `lib/services/export_service.dart` - 3箇所修正
- `release/ios/lib/services/export_service.dart` - 3箇所修正

### 🛠️ 技術的な変更
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

### 🎯 影響を受ける機能
1. **支出データCSVエクスポート** - `exportExpensesToCsv()`
2. **収入データCSVエクスポート** - `exportIncomesToCsv()`  
3. **全データCSVエクスポート** - `exportAllDataToCsv()`

## ✅ 検証結果

### 静的解析
```bash
PS D:\flutter\test\flutter_finance_app> flutter analyze
Analyzing flutter_finance_app...
No issues found! (ran in 5.8s)
```

**🎉 すべての警告が解決されました！**

## 📦 ダウンロード

- **APK**: `MoneyG-Android-v1.2.3.apk` (27.5MB)
- **ZIP**: `MoneyG-Android-v1.2.3.zip` (27.2MB)

## 🔗 技術情報

- **Flutter SDK**: 3.8.1+
- **share_plus**: ^11.0.0
- **ビルド環境**: Windows
- **ターゲット**: Android (Release)

## 📋 チェックリスト

- ✅ 非推奨API警告の修正
- ✅ `flutter analyze`でエラー0件確認
- ✅ CSVエクスポート機能の動作確認
- ✅ APKビルド成功
- ✅ リリースファイル作成完了

---

**このバージョンは主にコード品質の向上を目的としたメンテナンスリリースです。**  
**ユーザー向けの新機能追加はありませんが、アプリの安定性と将来的な互換性が向上しています。**
