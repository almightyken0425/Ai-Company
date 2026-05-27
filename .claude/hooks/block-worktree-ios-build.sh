#!/bin/bash
# PreToolUse hook：阻擋 worktree 內的 iOS build 指令
# 規範依據：ai-company CLAUDE.md「iOS 自驗策略」與 feedback memory ios-build-in-main-git-only

set -e

input=$(cat)
cmd=$(echo "$input" | jq -r '.tool_input.command // empty')
cwd=$(echo "$input" | jq -r '.cwd // empty')

# 只對 ai-company-worktrees 下的 iOS build 指令攔截
if echo "$cmd" | grep -qE '(xcodebuild|pod install|react-native run-ios|npm run ios|yarn ios)' \
   && echo "$cwd" | grep -q 'ai-company-worktrees/'; then
  cat >&2 <<EOF
✗ 偵測到要在 worktree 內跑 iOS build：
  command: $cmd
  cwd:     $cwd

依「iOS 自驗策略」（ai-company CLAUDE.md），rebuild 一律集中在主 git 跑，
且應由 /sim-review 自動觸發。請：
  1. 打 /sim-review，Claude 會自動判別「只動 JS / 動到原生」並執行對應流程
  2. 或 cd 到對應主 git（product/<產品>App）後再執行
EOF
  exit 2
fi

exit 0
