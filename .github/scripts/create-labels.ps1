# MoneyG Finance App用 GitHub ラベル設定スクリプト (PowerShell)
# このスクリプトを実行してプロジェクト管理用ラベルを一括作成

Write-Host "🏷️ MoneyG Finance App用 GitHub ラベルを作成中..." -ForegroundColor Green

# 優先度ラベル
Write-Host "📊 優先度ラベルを作成中..." -ForegroundColor Yellow
gh label create "priority: critical" --color "d73a4a" --description "緊急修正が必要" --force
gh label create "priority: high" --color "ff6900" --description "高優先度" --force
gh label create "priority: medium" --color "fbca04" --description "中優先度" --force
gh label create "priority: low" --color "0e8a16" --description "低優先度" --force

# タイプラベル
Write-Host "🔧 タイプラベルを作成中..." -ForegroundColor Yellow
gh label create "type: bug" --color "d73a4a" --description "バグ修正" --force
gh label create "type: feature" --color "a2eeef" --description "新機能" --force
gh label create "type: enhancement" --color "84b6eb" --description "機能改善" --force
gh label create "type: documentation" --color "0052cc" --description "ドキュメント" --force
gh label create "type: security" --color "ee0701" --description "セキュリティ" --force
gh label create "type: performance" --color "fef2c0" --description "パフォーマンス" --force

# プラットフォームラベル
Write-Host "📱 プラットフォームラベルを作成中..." -ForegroundColor Yellow
gh label create "platform: android" --color "3ddc84" --description "Android固有" --force
gh label create "platform: ios" --color "007aff" --description "iOS固有" --force
gh label create "platform: both" --color "6f42c1" --description "両プラットフォーム" --force

# ステータスラベル
Write-Host "📋 ステータスラベルを作成中..." -ForegroundColor Yellow
gh label create "status: planning" --color "d4c5f9" --description "計画中" --force
gh label create "status: in-progress" --color "0052cc" --description "作業中" --force
gh label create "status: review" --color "fbca04" --description "レビュー中" --force
gh label create "status: testing" --color "f9d0c4" --description "テスト中" --force
gh label create "status: resolved" --color "0e8a16" --description "解決済み" --force
gh label create "status: implemented" --color "0e8a16" --description "実装済み" --force

# サイズラベル
Write-Host "📏 サイズラベルを作成中..." -ForegroundColor Yellow
gh label create "size: XS" --color "c2e0c6" --description "1-2時間" --force
gh label create "size: S" --color "7dbedb" --description "半日" --force
gh label create "size: M" --color "5319e7" --description "1-2日" --force
gh label create "size: L" --color "f9d0c4" --description "3-5日" --force
gh label create "size: XL" --color "d93f0b" --description "1週間以上" --force

# 特殊ラベル
Write-Host "⭐ 特殊ラベルを作成中..." -ForegroundColor Yellow
gh label create "good first issue" --color "7057ff" --description "初心者におすすめ" --force
gh label create "help wanted" --color "008672" --description "コミュニティの協力求む" --force
gh label create "breaking change" --color "d93f0b" --description "破壊的変更" --force
gh label create "dependencies" --color "0366d6" --description "依存関係更新" --force

Write-Host "✅ すべてのラベルが正常に作成されました！" -ForegroundColor Green
Write-Host ""
Write-Host "🔄 次のステップ:" -ForegroundColor Cyan
Write-Host "1. 既存issueに新しいラベルを追加"
Write-Host "2. GitHub Projectボードを作成"
Write-Host "3. 自動化ルールを設定"
Write-Host ""
Write-Host "📋 既存issueを更新するには以下を実行:" -ForegroundColor Cyan
Write-Host "gh issue edit 5 --add-label 'type: feature,priority: medium,platform: both'"
Write-Host "gh issue edit 4 --add-label 'type: bug,priority: high,platform: both,status: resolved'"
Write-Host "gh issue edit 3 --add-label 'type: feature,priority: high,platform: both,status: implemented'"
