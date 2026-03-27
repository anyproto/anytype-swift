#!/bin/bash

# Dangerous Git Guard (PreToolUse on Bash)
# Catches dangerous git patterns that prefix-based deny rules miss,
# e.g. "git push origin main --force" where --force is not right after push.

set -eo pipefail

# Read tool input from stdin
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null || echo "")

# Skip non-git commands
if [[ ! "$COMMAND" =~ ^[[:space:]]*git[[:space:]] ]]; then
    exit 0
fi

# Check for force push flags anywhere in a git push command
if [[ "$COMMAND" =~ ^[[:space:]]*git[[:space:]]+push ]]; then
    if [[ "$COMMAND" =~ --force|\ -f\ |\ -f$|--force-with-lease ]]; then
        cat <<'BLOCK'
{
  "decision": "block",
  "reason": "Force push is forbidden. Use regular git push instead."
}
BLOCK
        exit 0
    fi
fi

# Check for git reset anywhere (backup check for deny rules)
if [[ "$COMMAND" =~ ^[[:space:]]*git[[:space:]]+reset ]]; then
    cat <<'BLOCK'
{
  "decision": "block",
  "reason": "git reset is forbidden. Use git revert or create a new commit instead."
}
BLOCK
    exit 0
fi

# Check for git clean
if [[ "$COMMAND" =~ ^[[:space:]]*git[[:space:]]+clean ]]; then
    cat <<'BLOCK'
{
  "decision": "block",
  "reason": "git clean is forbidden. Remove files manually instead."
}
BLOCK
    exit 0
fi

# Check for destructive checkout (git checkout . or git checkout -- .)
if [[ "$COMMAND" =~ ^[[:space:]]*git[[:space:]]+checkout[[:space:]]+(--[[:space:]]+)?\.([[:space:]]|$) ]]; then
    cat <<'BLOCK'
{
  "decision": "block",
  "reason": "Destructive git checkout (discard all changes) is forbidden. Discard specific files instead."
}
BLOCK
    exit 0
fi

# Check for destructive restore (git restore .)
if [[ "$COMMAND" =~ ^[[:space:]]*git[[:space:]]+restore[[:space:]]+\. ]]; then
    cat <<'BLOCK'
{
  "decision": "block",
  "reason": "git restore . (discard all changes) is forbidden. Restore specific files instead."
}
BLOCK
    exit 0
fi

# Check for force branch delete
if [[ "$COMMAND" =~ ^[[:space:]]*git[[:space:]]+branch[[:space:]]+-D ]]; then
    cat <<'BLOCK'
{
  "decision": "block",
  "reason": "git branch -D (force delete) is forbidden. Use git branch -d for safe deletion."
}
BLOCK
    exit 0
fi

exit 0
