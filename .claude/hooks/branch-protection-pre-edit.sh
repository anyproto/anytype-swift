#!/bin/bash

# Branch Protection Hook (PreToolUse)
# This hook warns/blocks edits on protected branches (develop, main)

set -euo pipefail

# Protected branches
PROTECTED_BRANCHES=("develop" "main" "master" "release")

# Get the current branch
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "")

# If not in a git repo or can't determine branch, allow
if [ -z "$CURRENT_BRANCH" ]; then
    exit 0
fi

# Check if current branch is protected
IS_PROTECTED=false
for branch in "${PROTECTED_BRANCHES[@]}"; do
    if [ "$CURRENT_BRANCH" = "$branch" ]; then
        IS_PROTECTED=true
        break
    fi
done

# If protected, output warning (non-blocking by default)
if [ "$IS_PROTECTED" = true ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "⚠️  PROTECTED BRANCH WARNING"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "You are editing files on the '$CURRENT_BRANCH' branch."
    echo "This is a protected branch - direct edits are discouraged."
    echo ""
    echo "Consider:"
    echo "  1. Create a feature branch: git checkout -b ios-XXXX-description"
    echo "  2. Make your changes on the feature branch"
    echo "  3. Create a PR to merge into $CURRENT_BRANCH"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # To make this blocking, uncomment the following line:
    # exit 2  # Exit code 2 = blocking error
fi

exit 0
