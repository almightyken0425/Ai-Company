#!/bin/bash
# PreToolUse hook：阻擋 worktree 內的 iOS build 指令
# 規範依據：ai-company CLAUDE.md「Port 協作規範」與 feedback memory ios-build-in-main-git-only
# 2026-07 包 6：jq 改 python3（本機無 jq、set -e 下必死）、cwd 正規化吃反斜線、matcher 擴 PowerShell

INPUT=$(cat)
command -v python3 >/dev/null 2>&1 || exit 0   # python3 缺席 fail-open（本 hook 為提示層防線）

VERDICT=$(printf '%s' "$INPUT" | python3 -c '
import json, re, sys
try:
    d = json.load(sys.stdin)
except Exception:
    print("PASS"); sys.exit(0)
ti = d.get("tool_input") or {}
cmd = ti.get("command") or ""
cwd = (d.get("cwd") or "").replace("\\", "/").lower()
build = re.search(r"(xcodebuild|pod install|react-native run-ios|npm run ios|yarn ios)", cmd)
if build and "ai-company-worktrees/" in cwd:
    print("BLOCK")
    print(cmd.splitlines()[0][:200] if cmd else "")
    print(cwd)
else:
    print("PASS")
' 2>/dev/null) || VERDICT="PASS"

case "$VERDICT" in
  BLOCK*)
    CMD_LINE=$(printf '%s\n' "$VERDICT" | sed -n '2p')
    CWD_LINE=$(printf '%s\n' "$VERDICT" | sed -n '3p')
    cat >&2 <<EOF
✗ 偵測到要在 worktree 內跑 iOS build：
  command: $CMD_LINE
  cwd:     $CWD_LINE

依「Port 協作規範」（ai-company CLAUDE.md），build 一律集中在主 git 跑，
且應由 /sim-review 自動觸發。請：
  1. 打 /sim-review，Claude 會自動判別「只動 JS / 動到原生」並執行對應流程
  2. 或 cd 到對應主 git（product/<產品>/no5_product_development/<module>/）後再執行
EOF
    exit 2
    ;;
esac
exit 0
