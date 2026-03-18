#!/bin/bash
# COS Router: detects "chief of staff" in user prompt,
# pre-loads products.md, and injects routing context
# so main Claude can route without any file reads.

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt')
CWD=$(echo "$INPUT" | jq -r '.cwd')

# Only activate if prompt contains "chief of staff" (case insensitive)
if ! echo "$PROMPT" | grep -qiE "chief.of.staff|chief-of-staff"; then
    exit 0
fi

PRODUCTS_FILE="$CWD/workspace/company/products.md"
if [ ! -f "$PRODUCTS_FILE" ]; then
    exit 0
fi

PRODUCTS_CONTENT=$(cat "$PRODUCTS_FILE")

# Inject products.md content + routing instruction as system message
jq -n --arg products "$PRODUCTS_CONTENT" '{
    "systemMessage": "=== Chief of Staff 模式已啟動 ===\nproducts.md 內容已預載（不需要再 Read）：\n\n\($products)\n\n請根據 CLAUDE.md 的路由表和上方內容，直接輸出路由計畫，等待確認後 invoke specialist。"
}'
