#!/bin/bash

# Bash Safety Guard (PreToolUse on Bash)
# Blocks bash patterns that trigger un-bypassable Claude Code security prompts.

set -eo pipefail

# Read tool input from stdin
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null || echo "")

# Block find -exec with \; (triggers security prompt for backslash before shell operator)
# Suggest using {} + or piping to xargs instead
if [[ "$COMMAND" =~ \\\\?\; ]] && [[ "$COMMAND" =~ -exec ]]; then
    cat <<'BLOCK'
{
  "decision": "block",
  "reason": "find -exec with \\; triggers a security prompt. Use 'find ... -exec cmd {} +' (with + instead of \\;) or 'find ... | xargs cmd' instead."
}
BLOCK
    exit 0
fi

exit 0
