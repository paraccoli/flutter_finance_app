````markdown
# 🍎 MoneyG Finance App - iOS版 インストール手順

> **バージョン**: v1.3.1  
> **対象**: iOS 13.0 以上  
> **リリース日**: 2025年7月3日

---

## 📋 必要な環境

### 💻 開発環境
- **macOS**: 10.15 (Catalina) 以上
- **Xcode**: 12.0 以上
- **Flutter SDK**: 3.8.1 以上
- **CocoaPods**: 1.10.0 以上

### 📱 対象デバイス
- **iPhone**: 6s 以降 (iOS 13.0+)
- **iPad**: 第5世代以降 (iPadOS 13.0+)
- **iPad Pro**: 全モデル対応

---

## 🚀 インストール手順

### 1. 📥 プロジェクトのセットアップ

```bash
# 1. 依存関係のインストール
flutter pub get

# 2. CocoaPodsの更新
cd ios
pod install
cd ..

# 3. iOS Runnerのクリーンビルド
flutter clean
flutter pub get
```

### 2. 🔧 Xcodeでの設定

#### a) プロジェクトを開く
```bash
open ios/Runner.xcworkspace
```

#### b) 署名設定
1. **Runner** プロジェクトを選択
2. **Signing & Capabilities** タブ
3. **Team** を選択（Apple Developer Account必須）
4. **Bundle Identifier** を変更（例：`com.yourcompany.moneygfinance`）

#### c) デプロイメントターゲット確認
- **iOS Deployment Target**: 13.0 以上に設定

### 3. 📱 デバイスでのテスト

```bash
# デバイス接続確認
flutter devices

# iOS実機での実行
flutter run -d [device-id]
```

### 4. 🏗️ リリースビルド

```bash
# iOS用リリースビルド（アイコン最適化無効）
flutter build ios --no-tree-shake-icons

# Archive作成（Xcode）
# Product → Archive
```

---

## 🆕 v1.3.1 新機能対応

### 🏷️ カスタムカテゴリ機能
- **データベース**: SQLiteでカスタムカテゴリを管理
- **UI**: Material Iconsライブラリ使用
- **設定**: iOS設定アプリとの統合

### 🎨 テーマカスタマイズ
- **iOS Design Guidelines**: ライト/ダークモード対応
- **Dynamic Type**: iOS標準フォントサイズ対応
- **アクセシビリティ**: VoiceOver完全対応

---

## ⚙️ 設定ファイルの説明

### 📄 Info.plist設定

```xml
<!-- アプリ名設定 -->
<key>CFBundleDisplayName</key>
<string>MoneyG Finance</string>

<!-- バージョン情報 -->
<key>CFBundleShortVersionString</key>
<string>1.3.1</string>
<key>CFBundleVersion</key>
<string>1</string>

<!-- 通知権限 -->
<key>UIUserNotificationSettings</key>
<dict>
    <key>UIUserNotificationTypesAllowed</key>
    <array>
        <string>UIUserNotificationTypeAlert</string>
        <string>UIUserNotificationTypeBadge</string>
        <string>UIUserNotificationTypeSound</string>
    </array>
</dict>

<!-- ファイルアクセス権限 -->
<key>LSSupportsOpeningDocumentsInPlace</key>
<true/>
<key>UIFileSharingEnabled</key>
<true/>

<!-- カスタムカテゴリ機能用 -->
<key>UISupportsDocumentBrowser</key>
<true/>
```

### 🔐 セキュリティ設定

```xml
<!-- プライバシー設定 -->
<key>NSPhotoLibraryUsageDescription</key>
<string>CSVファイルの保存にフォトライブラリへのアクセスが必要です</string>

<key>NSDocumentsFolderUsageDescription</key>
<string>CSVファイルのインポート・エクスポートにDocumentsフォルダへのアクセスが必要です</string>

<!-- カメラアクセス（レシート撮影機能用） -->
<key>NSCameraUsageDescription</key>
<string>レシートの写真撮影機能でカメラアクセスが必要です</string>
```

---

## 🛠️ トラブルシューティング

### ❌ よくある問題

#### 1. **コード署名エラー**
```
解決方法:
1. Apple Developer Accountの確認
2. Bundle Identifierの重複確認
3. Provisioning Profileの更新
```

#### 2. **v1.3.1アイコンビルドエラー**
```bash
# アイコン最適化を無効にしてビルド
flutter build ios --no-tree-shake-icons
```

#### 3. **依存関係エラー**
```bash
# 依存関係のクリーンインストール
flutter clean
rm -rf ios/Pods
rm ios/Podfile.lock
flutter pub get
cd ios && pod install && cd ..
```

#### 4. **カスタムカテゴリデータベースエラー**
```bash
# データベースマイグレーション確認
flutter logs --device ios
```

### 🔧 デバッグコマンド

```bash
# Flutter診断
flutter doctor -v

# iOS固有の診断
flutter doctor --verbose

# パッケージ依存関係確認
flutter pub deps

# カスタムカテゴリ機能の動作確認
flutter run -d ios --debug
```

---

## 🔒 セキュリティ・プライバシー

### 🛡️ ローカル保存の利点

- **完全オフライン**: インターネット接続不要
- **データ主権**: ユーザーが完全制御
- **プライバシー保護**: 外部送信一切なし
- **iOS Keychain統合**: ハードウェアレベル暗号化

### 🔐 データ暗号化

```dart
// iOS Keychain使用例
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage(
  iOptions: IOSOptions(
    accessibility: IOSAccessibility.when_unlocked_this_device_only,
  ),
);

// カスタムカテゴリデータの暗号化
await storage.write(
  key: 'custom_categories_backup',
  value: encryptedCategoriesJson,
);
```

---

## 📱 v1.3.1 iOS特有機能

### 🍎 iOS統合機能
- **Siri Shortcuts**: 支出・収入の音声登録
- **Widgets**: ホーム画面ウィジェット対応
- **Context Menu**: 3D Touch/Haptic Touchサポート
- **Share Extension**: 他アプリからのデータ共有

### 🎨 iOS Design Language
- **SF Symbols**: システムアイコンとの統合
- **Dynamic Type**: アクセシビリティ対応
- **Dark Mode**: システム設定と連携
- **Haptic Feedback**: タッチフィードバック

---

## 📞 サポート・問い合わせ

### 🐛 バグ報告
- **GitHub Issues**: [Issues ページ](https://github.com/paraccoli/flutter_finance_app/issues)
- **ラベル**: `iOS`, `bug`, `v1.3.1`

### 💡 機能提案
- **GitHub Discussions**: 新機能のアイデア共有
- **Feature Request**: テンプレート使用

### 🍎 iOS固有の問題
- **App Store審査**: 審査ガイドライン対応
- **TestFlight**: ベータテスト配信サポート

---

## 📚 関連ドキュメント

<<<<<<< Updated upstream
- 📖 [メインREADME](README.md)
- 🔒 [セキュリティポリシー](SECURITY.md)
- 🤝 [コントリビューションガイド](CONTRIBUTING.md)
- 📄 [プライバシーポリシー](PRIVACY.md)

---

=======
- 📖 [メインREADME](../../README.md)
- 🍎 [iOS版機能説明](FEATURES_iOS.md)
- 📝 [リリースノート v1.3.1](../../RELEASE_NOTES_v1.3.1.md)
- 🔒 [セキュリティポリシー](../../SECURITY.md)
- 🤝 [コントリビューションガイド](../../CONTRIBUTING.md)
- 📄 [プライバシーポリシー](../../PRIVACY.md)

---

## 🎯 次のステップ

1. ✅ **環境準備**: Xcode・Flutterセットアップ
2. 🔧 **ビルド実行**: デバッグ・リリースビルド
3. 📱 **デバイステスト**: 実機での動作確認
4. 🏷️ **カスタムカテゴリ**: 新機能の動作確認
5. 🚀 **デプロイ**: TestFlight/App Store配信
6. 📈 **フィードバック**: ユーザー評価・改善
>>>>>>> Stashed changes

---

<div align="center">
  <p>🍎 <strong>MoneyG Finance App - iOS版 v1.3.1</strong> 🍎</p>
  <p>📱 <em>カスタムカテゴリ対応・安全安心な家計管理</em> 📱</p>
  <p>🔒 <em>あなたのデータは、あなたのiOSデバイスに</em> 🔒</p>
</div>

---

*iOS版 v1.3.1 インストール手順*  
*最終更新: 2025年7月3日*

````
