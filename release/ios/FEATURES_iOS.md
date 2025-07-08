# 🍎 MoneyG Finance App - iOS版機能説明

> **バージョン**: v1.3.1  
> **対象**: iOS 13.0 以上  
> **リリース日**: 2025年7月3日

---

## 📱 iOS版の特徴

### 🎨 iOS Native Design

#### Apple Design Guidelines準拠
- **Human Interface Guidelines**: Appleの最新デザイン指針に完全準拠
- **SF Symbols**: システム標準アイコンとの調和
- **Dynamic Type**: アクセシビリティ対応のフォントサイズ自動調整
- **Dark Mode**: システム設定との完全連携

#### iOS特有のUX
- **Navigation**: iOSスタイルのナビゲーション
- **Modal Presentation**: システム標準のモーダル表示
- **Context Menu**: 3D Touch / Haptic Touchサポート
- **Haptic Feedback**: タッチ時の触覚フィードバック

---

## 🏷️ v1.3.1 新機能

### ✨ カスタムカテゴリ機能

#### 作成・編集機能
- **無制限カテゴリ**: 収入・支出カテゴリを自由に作成
- **視覚的カスタマイズ**: 20色のカラーパレット + Material Icons
- **リアルタイムプレビュー**: 編集中の変更をその場で確認
- **重複防止**: 同名カテゴリの自動検出・防止

#### iOS特有の実装
- **Core Data統合**: iOSのデータ管理フレームワーク活用
- **Keychain Services**: セキュアなカテゴリデータ保存
- **Settings Bundle**: iOS設定アプリからのカテゴリ管理
- **Siri Shortcuts**: 音声でのカテゴリ選択対応

### 🎨 テーマシステム強化

#### iOS連携機能
- **System Appearance**: システムの外観設定と自動同期
- **Adaptive Colors**: ライト/ダークモードでの色適応
- **Accessibility**: 高コントラスト・透明度軽減対応
- **Widget Support**: ホーム画面ウィジェットのテーマ連携

---

## 📊 データ管理・分析

### 💾 ローカルストレージ

#### iOS最適化
- **SQLite + Core Data**: ダブルレイヤーでのデータ保護
- **Background App Refresh**: バックグラウンド更新対応
- **iCloud Backup**: 自動バックアップ（オプション）
- **Keychain**: 暗号化されたセキュアストレージ

### 📈 分析機能

#### iOS専用機能
- **Charts Framework**: Apple純正グラフライブラリ使用
- **HealthKit連携**: 健康データとの統合（将来実装予定）
- **Screen Time**: アプリ使用統計との連携
- **Shortcuts App**: 自動化ワークフロー対応

---

## 🔒 セキュリティ・プライバシー

### 🛡️ iOS Security Framework

#### ハードウェアレベル保護
- **Secure Enclave**: 生体認証データの暗号化
- **Keychain Services**: システムレベルの暗号化ストレージ
- **App Transport Security**: 通信のセキュリティ強化
- **Code Signing**: アプリの完全性保証

#### プライバシー保護
```swift
// プライバシー保護の実装例
import CryptoKit

class SecureDataManager {
    private let encryptionKey = SymmetricKey(size: .bits256)
    
    func encryptSensitiveData(_ data: Data) throws -> Data {
        let sealedData = try AES.GCM.seal(data, using: encryptionKey)
        return sealedData.combined!
    }
}
```

---

## 🚀 パフォーマンス最適化

### ⚡ iOS最適化

#### メモリ管理
- **Automatic Reference Counting**: メモリリーク防止
- **Lazy Loading**: 必要時のみデータ読み込み
- **Image Optimization**: Retina Display対応画像最適化
- **Core Animation**: 60fps滑らかアニメーション

#### バッテリー効率
- **Background Processing**: 効率的なバックグラウンド処理
- **Location Services**: 必要最小限の位置情報使用
- **Network Optimization**: 通信の最適化（将来機能用）

---

## 🎯 iOS統合機能

### 📱 システム統合

#### Siri & Shortcuts
```swift
// Siri Shortcuts実装例
import Intents
import IntentsUI

class AddExpenseIntentHandler: NSObject, AddExpenseIntentHandling {
    func handle(intent: AddExpenseIntent) async -> AddExpenseIntentResponse {
        // 支出追加のロジック
        return AddExpenseIntentResponse(code: .success, userActivity: nil)
    }
}
```

#### Widget Extensions
- **Today View**: ホーム画面での残高表示
- **Lock Screen**: iOS 16+のロック画面ウィジェット
- **Interactive Widget**: iOS 17+のインタラクティブ機能
- **Live Activities**: リアルタイム更新表示

### 📂 ファイル統合

#### Document Provider
- **Files App**: システムファイルアプリとの統合
- **CSV Export**: 標準形式でのデータ書き出し
- **AirDrop**: デバイス間でのデータ共有
- **Share Extension**: 他アプリからのデータ取り込み

---

## ♿ アクセシビリティ

### 🎯 iOS Accessibility

#### VoiceOver対応
```swift
// VoiceOver対応実装例
expenseButton.accessibilityLabel = "支出を追加"
expenseButton.accessibilityHint = "新しい支出項目を記録します"
expenseButton.accessibilityTraits = .button
```

#### その他の支援技術
- **Switch Control**: 外部スイッチでの操作
- **Voice Control**: 音声でのアプリ操作
- **Guided Access**: 特定機能への集中モード
- **Dynamic Type**: システム文字サイズとの連携

---

## 🔧 開発・デバッグ

### 🛠️ iOS開発ツール

#### Xcode統合
- **Interface Builder**: ビジュアルUI設計
- **Instruments**: パフォーマンス分析
- **Simulator**: 各種デバイス・OS版でのテスト
- **TestFlight**: ベータ版配信プラットフォーム

#### デバッグ機能
```swift
// iOS専用デバッグ
#if DEBUG
import os.log

let logger = Logger(subsystem: "com.moneygfinance.app", category: "CustomCategory")
logger.debug("カスタムカテゴリが作成されました: \(categoryName)")
#endif
```

---

## 📋 システム要件

### 💻 開発環境
- **macOS**: 10.15 (Catalina) 以上
- **Xcode**: 12.0 以上
- **Flutter**: 3.8.1 以上
- **CocoaPods**: 1.10.0 以上

### 📱 動作環境
- **iOS**: 13.0 以上
- **iPadOS**: 13.0 以上
- **iPhone**: 6s 以降
- **iPad**: 第5世代以降
- **iPad Pro**: 全モデル

### 💾 ストレージ
- **最小容量**: 50MB
- **推奨容量**: 100MB以上
- **データベース**: 10MB〜（使用状況により）

---

<div align="center">
  <p>🍎 <strong>MoneyG Finance App - iOS版 v1.3.1</strong> 🍎</p>
  <p>📱 <em>Apple純正技術で作られた安全な家計管理</em> 📱</p>
  <p>🔒 <em>プライバシーファースト・iOS最適化</em> 🔒</p>
</div>

---

*iOS版 v1.3.1 機能説明*  
*最終更新: 2025年7月3日*
