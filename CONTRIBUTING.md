# 🤝 MoneyG Finance App - コントリビューションガイド

> **MoneyG Finance App**への貢献をお考えいただき、ありがとうございます！  
> コミュニティの力で、より良い家計管理アプリを作り上げましょう。

---

## 🎯 コントリビューションの概要

MoneyG Finance Appは、プライバシーを重視した個人家計管理アプリです。Flutter技術を使用してAndroid・iOS両プラットフォームに対応し、完全ローカル保存によりユーザーのプライバシーを保護しています。

### 🌟 歓迎するコントリビューション

- 🐛 **バグ修正**: アプリの安定性向上
- ✨ **新機能**: ユーザー体験の向上
- 📚 **ドキュメント**: 使いやすさの改善
- 🧪 **テスト**: 品質保証の強化
- 🎨 **UI/UX改善**: デザイン・ユーザビリティの向上
- 🔒 **セキュリティ**: プライバシー保護の強化

---

## 🚀 クイックスタート

### 1. 🍴 リポジトリをフォーク

右上の「Fork」ボタンをクリックしてリポジトリをフォークしてください。

### 2. 📁 ローカル環境のセットアップ

```bash
# フォークしたリポジトリをクローン
git clone https://github.com/your-username/flutter_finance_app.git
cd flutter_finance_app

# 依存関係をインストール
flutter pub get

# 動作確認
flutter doctor
flutter analyze
flutter test
```

### 3. 🔧 開発環境

#### 必要な環境
- **Flutter SDK**: 3.32.2 以上
- **Dart SDK**: 3.8.1 以上
- **Android Studio**: Android開発用
- **Xcode**: iOS開発用 (macOSのみ)

#### 推奨IDE設定
- **VS Code**: Flutter拡張機能
- **Android Studio**: Flutter/Dartプラグイン

---

## 📋 開発プロセス

### 🔄 ワークフロー

1. **Issue確認**: [既存のIssue](../../issues)で作業内容を確認
2. **ブランチ作成**: 機能/修正用のブランチを作成
3. **開発**: コーディング、テスト、ドキュメント更新
4. **テスト**: 全テストの通過を確認
5. **コミット**: 明確なコミットメッセージ
6. **プルリクエスト**: レビュー依頼

### 🌿 ブランチ命名規則

```bash
feature/機能名        # 新機能
bugfix/バグ名         # バグ修正
hotfix/緊急修正名     # 緊急修正
docs/ドキュメント名    # ドキュメント
refactor/リファクタ名  # リファクタリング
```

**例**:
```bash
git checkout -b feature/category-customization
git checkout -b bugfix/budget-calculation-error
git checkout -b docs/installation-guide
```

### 💬 コミットメッセージ

#### フォーマット
```
<タイプ>: <簡潔な説明>

<詳細な説明>（必要に応じて）

Fixes #issue番号
```

#### タイプ一覧
- `feat`: 新機能
- `fix`: バグ修正
- `docs`: ドキュメント
- `style`: コードスタイル
- `refactor`: リファクタリング
- `test`: テスト
- `chore`: その他の作業

#### 例
```bash
git commit -m "feat: カテゴリカスタマイズ機能を追加

ユーザーが独自のカテゴリを作成・編集・削除できる機能を実装
- カテゴリ一覧画面の実装
- カテゴリ編集ダイアログの追加
- データベーススキーマの更新

Fixes #12"
```

---

## 🧪 テスト・品質管理

### 📊 必須チェック

開発完了後、以下を必ず実行してください：

```bash
# 1. 静的解析
flutter analyze

# 2. テスト実行
flutter test

# 3. フォーマット確認
dart format --set-exit-if-changed .

# 4. アプリビルド確認
flutter build apk    # Android
flutter build ios    # iOS (macOSのみ)
```

### 🎯 テストカバレッジ

- **単体テスト**: 新しいビジネスロジックには必須
- **ウィジェットテスト**: UI変更には推奨
- **統合テスト**: 重要な機能には推奨

### 📱 手動テスト項目

#### 基本動作確認
- [ ] アプリの起動・終了
- [ ] 各画面の表示
- [ ] データの登録・編集・削除
- [ ] 画面遷移の正常性

#### プラットフォーム別確認
- [ ] Android: API 21以上での動作
- [ ] iOS: iOS 13.0以上での動作
- [ ] レスポンシブデザインの確認

---

## 📤 プルリクエスト

### 🎯 作成前チェックリスト

- [ ] 既存のIssueとリンクしている
- [ ] ブランチ名が命名規則に従っている
- [ ] `flutter analyze`でエラーがない
- [ ] `flutter test`が全て通る
- [ ] 新機能にはテストを追加した
- [ ] ドキュメントを更新した（必要に応じて）
- [ ] 手動テストを実施した

### 📝 プルリクエストテンプレート

プルリクエスト作成時に[テンプレート](.github/pull_request_template.md)が自動で適用されます。必要な情報をすべて記入してください。

### 👀 レビュープロセス

1. **自動チェック**: CI/CDでの自動テスト
2. **コードレビュー**: メンテナーによるレビュー
3. **手動テスト**: 必要に応じて実機テスト
4. **マージ**: 承認後のマージ

---

## 🏷️ Issue・ラベル体系

### 🐛 バグ報告

**テンプレート**: [Bug Report](.github/ISSUE_TEMPLATE/bug_report.md)

#### 必要な情報
- 再現手順
- 期待される動作
- 実際の動作
- 環境情報（OS、デバイス、アプリバージョン）
- スクリーンショット（可能であれば）

### ✨ 機能要望

**テンプレート**: [Feature Request](.github/ISSUE_TEMPLATE/feature_request.md)

#### 必要な情報
- 解決したい問題
- 提案する解決策
- ユーザーストーリー
- UI/UXモックアップ（可能であれば）

### ❓ 質問・サポート

**テンプレート**: [Question](.github/ISSUE_TEMPLATE/question.md)

#### 利用シーン
- 使い方がわからない
- 技術的な質問
- 設定方法の確認

---

## 🎨 コーディング規約

### 🧑‍💻 Dartコーディング

#### 基本ルール
```dart
// ✅ 良い例
class ExpenseService {
  static const String _tableName = 'expenses';
  
  Future<List<Expense>> getExpensesByMonth(DateTime month) async {
    // 実装
  }
}

// ❌ 悪い例
class expenseService {
  String tableName = 'expenses';
  
  getExpenses(month) {
    // 実装
  }
}
```

#### 命名規則
- **クラス**: PascalCase (`ExpenseScreen`)
- **メソッド・変数**: camelCase (`getExpenses`)
- **定数**: SCREAMING_SNAKE_CASE (`MAX_ITEMS`)
- **プライベート**: アンダースコア始まり (`_helper`)

### 📁 ファイル構成

```
lib/
├── main.dart                 # アプリエントリーポイント
├── models/                   # データモデル
├── services/                 # ビジネスロジック
├── viewmodels/               # ViewModel層
├── views/                    # 画面コンポーネント
├── widgets/                  # 再利用可能ウィジェット
└── utils/                    # ユーティリティ
```

### 🎯 設計原則

- **単一責任の原則**: 1つのクラスは1つの責任
- **依存性注入**: テスタブルなコード
- **プラットフォーム対応**: Android・iOS両対応
- **パフォーマンス**: 60fps維持
- **プライバシー**: ローカル保存のみ

---

## 🔒 セキュリティ・プライバシー

### 🛡️ セキュリティ原則

1. **ローカルファースト**: すべてのデータはデバイス内保存
2. **暗号化**: センシティブデータの暗号化
3. **権限最小化**: 必要最小限の権限のみ
4. **セキュアコーディング**: 脆弱性の回避

### 📋 セキュリティチェックリスト

- [ ] 外部APIとの通信なし
- [ ] ローカルデータベースの暗号化
- [ ] ログ出力での機密情報の除外
- [ ] SQLインジェクション対策

### 🚨 脆弱性報告

セキュリティ上の問題を発見した場合：

1. **非公開Issue**: セキュリティラベル付きで報告
2. **詳細情報**: 再現手順と影響範囲
3. **責任ある開示**: 修正まで公開を控える

詳細は[セキュリティポリシー](SECURITY.md)をご覧ください。

---

## 🌐 国際化・アクセシビリティ

### 🗣️ 多言語対応

現在のサポート言語：
- 🇯🇵 日本語（メイン）
- 🇺🇸 英語（予定）

#### 追加予定言語
- 🇰🇷 韓国語
- 🇨🇳 中国語（簡体字）
- 🇪🇸 スペイン語

### ♿ アクセシビリティ

- **スクリーンリーダー対応**: セマンティックラベル
- **コントラスト**: WCAG準拠
- **フォントサイズ**: システム設定対応
- **操作性**: タッチ操作の最適化

---

## 📚 リソース・参考資料

### 📖 技術ドキュメント

- [Flutter公式ドキュメント](https://flutter.dev/docs)
- [Dart言語仕様](https://dart.dev/guides)
- [Material Design](https://material.io/design)

### 🔗 プロジェクトリンク

- **GitHubリポジトリ**: https://github.com/paraccoli/flutter_finance_app
- **Issue Tracker**: [Issues](../../issues)
- **Project Board**: [Projects](../../projects)

### 📱 関連ドキュメント

- [README](README.md): プロジェクト概要・インストール
- [プライバシーポリシー](PRIVACY.md): データ取り扱い
- [セキュリティポリシー](SECURITY.md): セキュリティ方針
- [iOS版ガイド](release/ios/INSTALL_iOS.md): iOS版セットアップ

---

## 🤝 コミュニティ・サポート

### 💬 コミュニケーション

- **GitHub Issues**: バグ報告・機能要望
- **GitHub Discussions**: 一般的な質問・アイデア
- **Pull Requests**: コード貢献

### 📞 連絡先

- **開発者**: [@paraccoli](https://github.com/paraccoli)
- **GitHub Issues**: 技術的な質問・バグ報告
- **Twitter**: [@paraccoli](https://twitter.com/paraccoli) (一般的な質問)

### 🎯 コミュニティ目標

- **包括性**: すべての人が歓迎される環境
- **品質**: 高品質なコード・UX
- **透明性**: オープンな開発プロセス
- **プライバシー**: ユーザーデータの保護

---

## 📋 よくある質問

### 🤔 開発に関するFAQ

**Q: 開発経験が少ないのですが、貢献できますか？**  
A: もちろんです！「good first issue」ラベルの付いたIssueから始めてください。

**Q: iOSデバイスがないのですが、iOS版の開発に貢献できますか？**  
A: Androidでの動作確認やコードレビューでも十分貢献になります。

**Q: 新機能のアイデアがあるのですが、どうすればいいですか？**  
A: [Feature Request](../../issues/new?template=feature_request.md)からアイデアを提案してください。

**Q: バグを見つけたのですが、修正方法がわかりません。**  
A: [Bug Report](../../issues/new?template=bug_report.md)で報告していただければ、チームで対応します。

### 🛠️ 技術的なFAQ

**Q: テストが失敗します。**  
A: `flutter clean && flutter pub get`を実行してから再度テストしてください。

**Q: Android Studioでビルドできません。**  
A: Android SDK、Gradle、Flutter SDKのバージョンを確認してください。

**Q: iOSシミュレーターが起動しません。**  
A: Xcodeの設定とシミュレーターの状態を確認してください。

---

## 📈 貢献の認識

### 🏆 コントリビューター

すべてのコントリビューターは以下の方法で認識されます：

- **README**: コントリビューターセクション
- **リリースノート**: 貢献内容の記載
- **GitHub Profile**: コントリビューション履歴

### 🎖️ 貢献レベル

- **🌟 First Time**: 初回コントリビューション
- **⭐ Regular**: 定期的な貢献
- **🌠 Core**: コアコントリビューター
- **💎 Maintainer**: メンテナー

---

## 📅 ロードマップ・将来計画

### 🎯 短期目標（v1.3.0 - 2025年7月）

- カテゴリカスタマイズ機能
- UI/UX改善
- パフォーマンス最適化

### 🚀 中期目標（v1.4.0 - 2025年8月）

- カレンダー連携機能
- 高度な分析機能
- 多言語対応

### 🌟 長期目標（v2.0.0 - 2025年末）

- Web版対応
- エンタープライズ機能
- AIによる支出予測

---

**📝 最終更新**: 2025年6月12日  
**📄 バージョン**: v1.0  
**👥 対象**: すべてのコントリビューター

> **MoneyG Finance App**への貢献に再度感謝いたします。  
> 一緒により良いアプリを作り上げましょう！ 🚀
