#!/bin/bash

# Bash Safety Guard (PreToolUse on Bash)
# Blocks bash patterns that trigger un-bypassable Claude Code security prompts.

set -euo pipefail

# Read tool input from stdin
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

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
