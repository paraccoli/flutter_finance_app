# 🗂️ GitHub Projects Configuration

## 📋 プロジェクトボード設定

### 🎯 MoneyG Finance App Development Board

#### カラム設定
- 📥 **Backlog** - 新規アイデア・要望
- 📝 **Todo** - 次スプリント予定
- 🔄 **In Progress** - 作業中
- 👀 **Review** - レビュー待ち
- 🧪 **Testing** - テスト中
- ✅ **Done** - 完了

#### 自動化ルール
- Issue作成時 → Backlog
- アサイン時 → In Progress
- PR作成時 → Review
- PR Merge時 → Done

---

## 🏷️ ラベル設定コマンド

以下のコマンドでラベルを一括設定できます：

```bash
# 優先度ラベル
gh label create "priority: critical" --color "d73a4a" --description "緊急修正が必要"
gh label create "priority: high" --color "ff6900" --description "高優先度"
gh label create "priority: medium" --color "fbca04" --description "中優先度"
gh label create "priority: low" --color "0e8a16" --description "低優先度"

# カテゴリラベル
gh label create "feature" --color "a2eeef" --description "新機能"
gh label create "enhancement" --color "84b6eb" --description "改善"
gh label create "documentation" --color "0052cc" --description "ドキュメント"
gh label create "security" --color "ee0701" --description "セキュリティ"
gh label create "performance" --color "fef2c0" --description "パフォーマンス"

# プラットフォームラベル
gh label create "platform: android" --color "3ddc84" --description "Android固有"
gh label create "platform: ios" --color "007aff" --description "iOS固有"
gh label create "platform: both" --color "6f42c1" --description "両プラットフォーム"

# 状態ラベル
gh label create "status: planning" --color "d4c5f9" --description "計画中"
gh label create "status: in-progress" --color "0052cc" --description "作業中"
gh label create "status: review" --color "fbca04" --description "レビュー中"
gh label create "status: testing" --color "f9d0c4" --description "テスト中"

# サイズラベル
gh label create "size: XS" --color "c2e0c6" --description "1-2時間"
gh label create "size: S" --color "7dbedb" --description "半日"
gh label create "size: M" --color "5319e7" --description "1-2日"
gh label create "size: L" --color "f9d0c4" --description "3-5日"
gh label create "size: XL" --color "d93f0b" --description "1週間以上"
```

---

## 📊 プロジェクトフィールド設定

### カスタムフィールド定義

#### Single Select Fields
- **Priority**: Critical, High, Medium, Low
- **Status**: Planning, In Progress, Review, Testing, Done
- **Platform**: Android, iOS, Both, Documentation
- **Size**: XS, S, M, L, XL

#### Number Fields
- **Story Points**: 見積もりポイント
- **Hours Estimated**: 工数見積もり(時間)
- **Hours Actual**: 実績工数(時間)

#### Date Fields
- **Start Date**: 開始予定日
- **Due Date**: 完了予定日
- **Completed Date**: 完了日

#### People Fields
- **Assignee**: 担当者
- **Reviewer**: レビュアー

---

## 🔄 ワークフロー自動化

### GitHub Actions連携

```yaml
# .github/workflows/project-automation.yml
name: Project Automation

on:
  issues:
    types: [opened, closed, assigned]
  pull_request:
    types: [opened, closed, merged]

jobs:
  update-project:
    runs-on: ubuntu-latest
    steps:
      - name: Add to project
        uses: actions/add-to-project@v0.4.0
        with:
          project-url: https://github.com/users/paraccoli/projects/1
          github-token: ${{ secrets.ADD_TO_PROJECT_PAT }}
```

---

## 📈 レポート設定

### ダッシュボードビュー

#### 開発進捗ダッシュボード
- **Burndown Chart**: マイルストーン進捗
- **Velocity Chart**: スプリント毎の完了ポイント
- **Cycle Time**: Issue→完了までの時間

#### 品質ダッシュボード
- **Bug Ratio**: 機能開発 vs バグ修正比率
- **Resolution Time**: バグ修正時間
- **Reopen Rate**: 再オープン率

---

## 🎯 使用開始手順

1. **GitHub Projects作成**
   ```
   1. リポジトリページ → Projects タブ
   2. "New project" クリック
   3. "Board" テンプレート選択
   4. プロジェクト名: "MoneyG Finance App Development"
   ```

2. **カラム設定**
   - Backlog, Todo, In Progress, Review, Testing, Done

3. **フィールド追加**
   - Priority, Platform, Size, Story Points等

4. **ラベル設定**
   - 上記のgh labelコマンド実行

5. **自動化設定**
   - プロジェクト設定 → Workflows で自動化ルール設定

6. **初期Issue作成**
   - v1.3.0向けのEpic/Feature作成
   - 既存のバックログをIssue化

---

## 📚 運用ガイド

### 日次運用
- [ ] In Progressの進捗確認
- [ ] 新規Issueのトリアージ
- [ ] ブロッカーの解決

### 週次運用
- [ ] スプリント進捗レビュー
- [ ] 次週の優先度調整
- [ ] バックログの整理

### 月次運用
- [ ] マイルストーン進捗確認
- [ ] ロードマップ更新
- [ ] メトリクス分析・改善
