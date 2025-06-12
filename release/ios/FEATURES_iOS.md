# 🍎 MoneyG Finance App - iOS版 特徴

> **v1.2.2 iOS版の主要機能と特徴**

---

## 🎯 iOS版の特徴

### 🔒 プライバシーファースト設計
- **完全ローカル保存**: データは一切外部に送信されません
- **iOS Keychain統合**: ハードウェアレベルの暗号化
- **サンドボックス保護**: iOS標準のセキュリティ機能活用
- **ゼロトラストネットワーク**: オフライン完結動作

### 🎨 iOS最適化
- **Human Interface Guidelines準拠**: ネイティブなiOS体験
- **Dynamic Type対応**: システムフォントサイズ設定に対応
- **Dark Mode完全対応**: システム設定と自動連動
- **SF Symbols活用**: iOSネイティブアイコン使用

### 📱 iOS特有機能
- **Face ID / Touch ID**: 生体認証によるアプリロック
- **Files アプリ統合**: CSVファイルの簡単アクセス
- **AirDrop共有**: ワンタップでのCSV共有
- **Notification Center**: iOS標準の通知システム

---

## 💰 アプリ機能一覧

### 基本機能
- ✅ 支出・収入記録
- ✅ カテゴリ別管理
- ✅ CSVインポート・エクスポート
- ✅ 月別レポート（棒グラフ）
- ✅ 予算管理（リアルタイム更新）
- ✅ NISA投資記録
- ✅ 資産分析・トレンド表示

### v1.2.2新機能
- 🆕 スワイプ操作（編集・削除）
- 🆕 自動月選択（データ存在月）
- 🆕 削除確認ダイアログ
- 🆕 予算リアルタイム反映
- 🆕 設定画面統合

---

## 📋 システム要件

```yaml
iOS要件:
  最小バージョン: iOS 13.0
  推奨バージョン: iOS 15.0+
  対応デバイス: 
    - iPhone 6s以降
    - iPad (第5世代)以降
    - iPad Pro (全モデル)
  
ストレージ: 50MB以上の空き容量
メモリ: 2GB以上推奨
```

---

## 🔧 含まれるファイル

```
MoneyG-iOS-v1.2.2/
├── ios/                    # iOS設定・プロジェクト
├── lib/                    # Dartソースコード
├── assets/                 # アプリアイコン・リソース
├── pubspec.yaml           # Flutter依存関係
├── README.md              # メインドキュメント
├── LICENSE                # MITライセンス
├── INSTALL_iOS.md         # iOS版インストール手順
├── RELEASE_NOTES_iOS_v1.2.2.md  # リリースノート
└── FEATURES_iOS.md        # この機能説明ファイル
```

---

## 🚀 クイックスタート

```bash
# 1. 依存関係インストール
flutter pub get

# 2. iOS Pods更新
cd ios && pod install && cd ..

# 3. iOS Simulatorで実行
flutter run -d ios

# 4. 実機での実行（デバイス接続後）
flutter run -d [device-id]
```

---

## 📞 サポート

**GitHub**: https://github.com/paraccoli/flutter_finance_app  
**Issues**: バグ報告・機能要望  
**Discussions**: 質問・アイデア共有

---

*iOS版 v1.2.2 - 安全・安心・プライベートな家計管理*
