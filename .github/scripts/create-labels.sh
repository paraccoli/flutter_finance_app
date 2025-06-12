#!/bin/bash

# GitHub Labels Setup Script for MoneyG Finance App
# Run this script to create all project management labels

echo "🏷️ Creating GitHub Labels for MoneyG Finance App..."

# Priority Labels
echo "📊 Creating Priority Labels..."
gh label create "priority: critical" --color "d73a4a" --description "緊急修正が必要" --force
gh label create "priority: high" --color "ff6900" --description "高優先度" --force
gh label create "priority: medium" --color "fbca04" --description "中優先度" --force
gh label create "priority: low" --color "0e8a16" --description "低優先度" --force

# Type Labels
echo "🔧 Creating Type Labels..."
gh label create "type: bug" --color "d73a4a" --description "バグ修正" --force
gh label create "type: feature" --color "a2eeef" --description "新機能" --force
gh label create "type: enhancement" --color "84b6eb" --description "機能改善" --force
gh label create "type: documentation" --color "0052cc" --description "ドキュメント" --force
gh label create "type: security" --color "ee0701" --description "セキュリティ" --force
gh label create "type: performance" --color "fef2c0" --description "パフォーマンス" --force

# Platform Labels
echo "📱 Creating Platform Labels..."
gh label create "platform: android" --color "3ddc84" --description "Android固有" --force
gh label create "platform: ios" --color "007aff" --description "iOS固有" --force
gh label create "platform: both" --color "6f42c1" --description "両プラットフォーム" --force

# Status Labels
echo "📋 Creating Status Labels..."
gh label create "status: planning" --color "d4c5f9" --description "計画中" --force
gh label create "status: in-progress" --color "0052cc" --description "作業中" --force
gh label create "status: review" --color "fbca04" --description "レビュー中" --force
gh label create "status: testing" --color "f9d0c4" --description "テスト中" --force
gh label create "status: resolved" --color "0e8a16" --description "解決済み" --force
gh label create "status: implemented" --color "0e8a16" --description "実装済み" --force

# Size Labels
echo "📏 Creating Size Labels..."
gh label create "size: XS" --color "c2e0c6" --description "1-2時間" --force
gh label create "size: S" --color "7dbedb" --description "半日" --force
gh label create "size: M" --color "5319e7" --description "1-2日" --force
gh label create "size: L" --color "f9d0c4" --description "3-5日" --force
gh label create "size: XL" --color "d93f0b" --description "1週間以上" --force

# Special Labels
echo "⭐ Creating Special Labels..."
gh label create "good first issue" --color "7057ff" --description "初心者におすすめ" --force
gh label create "help wanted" --color "008672" --description "コミュニティの協力求む" --force
gh label create "breaking change" --color "d93f0b" --description "破壊的変更" --force
gh label create "dependencies" --color "0366d6" --description "依存関係更新" --force

echo "✅ All labels created successfully!"
echo ""
echo "🔄 Next steps:"
echo "1. Update existing issues with new labels"
echo "2. Create GitHub Project board"
echo "3. Configure automation rules"
echo ""
echo "📋 Run the following to update existing issues:"
echo "gh issue edit 5 --add-label 'type: feature,priority: medium,platform: both'"
echo "gh issue edit 4 --add-label 'type: bug,priority: high,platform: both,status: resolved'"
echo "gh issue edit 3 --add-label 'type: feature,priority: high,platform: both,status: implemented'"
