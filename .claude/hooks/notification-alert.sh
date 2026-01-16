#!/bin/bash
# macOS notification hook for Claude Code
# Sends native notifications when Claude needs input

INPUT=$(cat)
NOTIFICATION_TYPE=$(echo "$INPUT" | jq -r '.notification_type // "unknown"')
MESSAGE=$(echo "$INPUT" | jq -r '.message // "Claude needs your attention"')

case "$NOTIFICATION_TYPE" in
  "permission_prompt")
    TITLE="🔐 Claude Permission Request"
    ;;
  "idle_prompt")
    TITLE="⏳ Claude Waiting for Input"
    ;;
  *)
    TITLE="🤖 Claude Code"
    ;;
esac

osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\" sound name \"Submarine\""
