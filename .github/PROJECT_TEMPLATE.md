# MoneyG Finance App - Project Board Template

## 🎯 Quick Setup Guide

### 1. Create GitHub Project
1. Go to: https://github.com/paraccoli/flutter_finance_app
2. Click "Projects" tab
3. Click "New project"
4. Select "Board" template
5. Name: "MoneyG Finance App Development"

### 2. Configure Board Columns
- 📥 Backlog
- 📝 Todo  
- 🔄 In Progress
- 👀 Review
- 🧪 Testing
- ✅ Done

### 3. Add Custom Fields
- Priority: Critical/High/Medium/Low
- Platform: Android/iOS/Both
- Size: XS/S/M/L/XL
- Story Points: Number field

### 4. Sample Issues for v1.3.0

#### Epic: カテゴリカスタマイズ機能
```
Title: [EPIC] ユーザー定義カテゴリ機能
Labels: feature, priority: high, platform: both, size: XL
Story Points: 21

Description:
ユーザーが独自のカテゴリを作成・編集・削除できる機能

Acceptance Criteria:
- [ ] カテゴリ一覧画面でカスタムカテゴリ表示
- [ ] カテゴリ追加・編集・削除機能
- [ ] カテゴリアイコン選択機能
- [ ] カテゴリ並び順変更機能
- [ ] 既存データとの互換性維持
```

#### Feature: カテゴリ作成UI
```
Title: [FEATURE] カテゴリ作成・編集画面の実装
Labels: feature, priority: high, platform: both, size: M
Story Points: 8

Description:
新規カテゴリの作成と既存カテゴリの編集を行うUI画面

Tasks:
- [ ] UI設計・モックアップ作成
- [ ] カテゴリ編集画面実装
- [ ] バリデーション機能
- [ ] プレビュー機能
```

#### Task: データベース設計
```
Title: [TASK] カスタムカテゴリ用DB設計
Labels: task, priority: high, platform: both, size: S
Story Points: 3

Description:
カスタムカテゴリを保存するためのデータベース設計

Technical Requirements:
- カテゴリテーブル設計
- マイグレーション作成
- 既存データとの互換性確保
```

#### Bug: 予算アラート改善
```
Title: [BUG] 予算アラートの通知タイミング改善
Labels: bug, priority: medium, platform: both, size: S
Story Points: 2

Description:
予算超過時の通知が遅延する問題の修正

Steps to Reproduce:
1. 予算設定
2. 支出入力で予算超過
3. 通知が即座に表示されない

Expected: 即座に通知表示
Actual: 数分後に通知
```

### 5. Automation Rules
- New issue → Backlog
- Assign user → In Progress
- Create PR → Review  
- Merge PR → Done

### 6. Sprint Planning Template

#### Sprint 1 (Week 1-2): Foundation
- カテゴリDB設計
- 基本UI実装
- データ移行検討

#### Sprint 2 (Week 3-4): Core Features  
- カテゴリCRUD機能
- アイコン選択機能
- バリデーション

#### Sprint 3 (Week 5-6): Polish & Test
- UI/UX改善
- 統合テスト
- パフォーマンス最適化

### 7. Success Metrics
- Velocity: 15-20 story points/sprint
- Bug ratio: <20% of total issues
- Cycle time: <5 days average
- User satisfaction: >4.5/5.0

### 8. Risk Mitigation
- Technical debt management
- Regular code reviews
- Continuous integration
- User feedback integration
