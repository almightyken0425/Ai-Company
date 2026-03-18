#!/bin/bash
# COS Guard: blocks exploration tools when chief-of-staff routing mode is active

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name')

# Check if COS routing mode is active
if [ ! -f "/tmp/cos_active" ]; then
    exit 0  # Not in COS mode, allow everything
fi

# In COS mode: only Read and Write are allowed
case "$TOOL_NAME" in
    "Read"|"Write")
        exit 0  # Allow: Read for products.md, Write to manage /tmp/cos_active
        ;;
    "Bash"|"Glob"|"Grep"|"WebFetch"|"WebSearch")
        echo "COS routing mode: $TOOL_NAME is blocked. chief-of-staff は Read products.md → invoke agent-workflow-manager の 2 ステップのみ。" >&2
        exit 2  # Block
        ;;
    "Agent")
        # Allow Agent tool only (for invoking agent-workflow-manager)
        # Clean up flag before handing off
        rm -f /tmp/cos_active
        exit 0
        ;;
    *)
        exit 0
        ;;
esac
