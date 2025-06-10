# 🤝 Contributing to MoneyG Finance App

MoneyG Finance Appへの貢献にご興味をお持ちいただき、ありがとうございます！このガイドでは、プロジェクトへの貢献方法について説明します。

## 📋 目次
- [貢献の種類](#貢献の種類)
- [開発環境のセットアップ](#開発環境のセットアップ)
- [コーディング規約](#コーディング規約)
- [プルリクエストの流れ](#プルリクエストの流れ)
- [Issue報告](#issue報告)
- [機能提案](#機能提案)
- [コミュニケーション](#コミュニケーション)

## 🎯 貢献の種類

### 🐛 バグ報告
- アプリのクラッシュや予期しない動作
- UI/UXの問題
- パフォーマンスの問題
- データ整合性の問題

### ✨ 機能提案
- 新しい機能のアイデア
- 既存機能の改善案
- UI/UXの改善提案

### 🔧 コード貢献
- バグ修正
- 新機能の実装
- パフォーマンス改善
- テストの追加
- ドキュメントの更新

### 📚 ドキュメント改善
- README更新
- コメントの追加・改善
- 使用方法の説明
- API ドキュメント

## 🛠️ 開発環境のセットアップ

### 必要なツール
- **Flutter SDK**: 3.24.5 以上
- **Dart SDK**: 3.5.4 以上
- **Android Studio** または **VS Code**
- **Git**

### 推奨する開発環境
- **IDE**: VS Code + Flutter/Dart 拡張機能
- **OS**: Windows 10+, macOS 10.14+, Ubuntu 18.04+

### セットアップ手順

1. **リポジトリのフォーク**
   ```bash
   # GitHubでリポジトリをフォーク
   git clone https://github.com/YOUR_USERNAME/flutter_finance_app.git
   cd flutter_finance_app
   ```

2. **依存関係のインストール**
   ```bash
   flutter pub get
   ```

3. **環境の確認**
   ```bash
   flutter doctor
   ```

4. **アプリの実行確認**
   ```bash
   flutter run
   ```

### ブランチ戦略
- `main`: 安定版リリース
- `develop`: 開発版（新機能の統合）
- `feature/機能名`: 新機能開発
- `fix/バグ名`: バグ修正
- `docs/ドキュメント名`: ドキュメント更新

## 📏 コーディング規約

### Dart/Flutter 規約
- [Effective Dart](https://dart.dev/guides/language/effective-dart) に従う
- `dart format` でコードフォーマット
- `dart analyze` でリント確認

### ファイル構成
```
lib/
├── main.dart
├── models/          # データモデル
├── services/        # ビジネスロジック
├── viewmodels/      # 状態管理
├── views/           # 画面（UI）
├── widgets/         # 再利用可能なウィジェット
└── utils/           # ユーティリティ
```

### 命名規約
- **クラス**: `PascalCase` (例: `ExpenseService`)
- **ファイル**: `snake_case` (例: `expense_service.dart`)
- **変数・関数**: `camelCase` (例: `calculateTotal`)
- **定数**: `UPPER_SNAKE_CASE` (例: `MAX_AMOUNT`)

### コメント規約
```dart
/// クラスや関数の説明（ドキュメンテーションコメント）
class ExpenseService {
  // 実装の詳細説明（単行コメント）
  void addExpense(Expense expense) {
    // TODO: バリデーション追加
    /* 
     * 複数行にわたる
     * 詳細な説明
     */
  }
}
```

### Git コミット規約
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Type（種類）**:
- `feat`: 新機能
- `fix`: バグ修正
- `docs`: ドキュメント更新
- `style`: コードスタイル修正
- `refactor`: リファクタリング
- `test`: テスト追加・修正
- `chore`: その他の変更

**例**:
```
feat(expense): CSVインポート機能を追加

- ファイル選択UI実装
- CSV解析ロジック追加
- エラーハンドリング強化

Closes #123
```

## 🔄 プルリクエストの流れ

### 1. Issue確認
- 既存のIssueを確認
- 新しい機能の場合は事前にIssueを作成して議論

### 2. ブランチ作成
```bash
git checkout -b feature/csv-import
```

### 3. 開発・テスト
- 機能実装
- テスト実行
- ドキュメント更新

### 4. コード品質確認
```bash
# フォーマット
dart format .

# 静的解析
dart analyze

# テスト実行
flutter test
```

### 5. プルリクエスト作成
- **タイトル**: 変更内容を簡潔に説明
- **説明**: 変更の背景・内容・影響を詳細に記載
- **チェックリスト**: 必要な確認項目をチェック

### プルリクエストテンプレート
```markdown
## 📝 変更内容
- 何を変更したか

## 🎯 変更理由
- なぜ変更が必要だったか

## 🧪 テスト方法
- どのようにテストしたか

## 📱 影響範囲
- [x] Android
- [x] iOS
- [ ] Web
- [ ] Desktop

## ✅ チェックリスト
- [ ] コードフォーマット済み
- [ ] 静的解析通過
- [ ] テスト追加・更新
- [ ] ドキュメント更新
```

## 🐛 Issue報告

### バグ報告テンプレート
```markdown
## 🐛 バグの説明
バグの詳細な説明

## 🔄 再現手順
1. XXXをクリック
2. YYYを入力
3. エラーが発生

## 🎯 期待される動作
本来はどのような動作であるべきか

## 📱 環境情報
- OS: Android 12 / iOS 15
- アプリバージョン: 1.2.2
- デバイス: Pixel 6 / iPhone 13

## 📎 追加情報
スクリーンショット、ログなど
```

### 優先度の設定
- 🔥 **Critical**: アプリクラッシュ、データ損失
- ⚠️ **High**: 主要機能が使用不可
- 📝 **Medium**: 軽微な機能不具合
- 💡 **Low**: 改善提案、軽微なUI問題

## ✨ 機能提案

### 提案テンプレート
```markdown
## 💡 機能の概要
提案する機能の説明

## 🎯 解決したい問題
現在の問題点や改善したい点

## 💭 提案する解決策
具体的な実装案

## 🎨 UI/UXモックアップ
画面設計やフロー図（可能であれば）

## 👥 ユーザーストーリー
As a [ユーザー種別]
I want [機能]
So that [目的]

## 🚨 優先度
- [ ] 🔥 High
- [ ] 📝 Medium  
- [ ] 💡 Low
```

## 💬 コミュニケーション

### 推奨チャンネル
- **GitHub Issues**: バグ報告、機能提案
- **GitHub Discussions**: 一般的な議論、質問
- **Pull Requests**: コードレビュー

### レスポンス時間
- **Issue返信**: 48時間以内
- **PR レビュー**: 72時間以内
- **緊急Bug**: 24時間以内

### コミュニケーション指針
- 建設的で敬意のあるコミュニケーション
- 技術的根拠に基づいた議論
- 初心者にも優しい説明を心がける

## 📜 ライセンス

このプロジェクトへの貢献により、あなたのコードは同じライセンス（MIT License）の下で公開されることに同意したものとみなされます。

## 🙏 謝辞

Money:G Finance Appプロジェクトにご協力いただき、ありがとうございます！すべての貢献者の努力により、より良いアプリを作ることができています。

---

## 📞 困ったときは

- 📖 [README.md](./README.md) を確認
- 🔍 [既存のIssues](https://github.com/paraccoli/flutter_finance_app/issues) を検索
- 💬 [GitHub Discussions](https://github.com/paraccoli/flutter_finance_app/discussions) で質問
- 📧 Issue作成で具体的な問題を報告

**Happy Coding! 🚀**
