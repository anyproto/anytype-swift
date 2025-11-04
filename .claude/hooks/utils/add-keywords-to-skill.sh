#!/bin/bash

# Auto-Learning Utility
# Adds keywords to a skill's configuration for improved auto-activation

set -euo pipefail

# Usage check
if [ $# -lt 2 ]; then
    echo "Usage: $0 <skill-name> <keyword1> [keyword2] [keyword3] ..."
    echo ""
    echo "Example:"
    echo "  $0 localization-developer \"membership\" \"tiers\" \"settings\""
    exit 1
fi

SKILL_NAME=$1
shift
NEW_KEYWORDS=("$@")

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_RULES="$SCRIPT_DIR/../skill-rules.json"
LOG_DIR="$SCRIPT_DIR/../../logs"
LOG_FILE="$LOG_DIR/skill-learning.log"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Validate skill exists
if ! jq -e ".skills[\"$SKILL_NAME\"]" "$SKILL_RULES" > /dev/null 2>&1; then
    echo "❌ Error: Skill '$SKILL_NAME' not found in skill-rules.json"
    echo ""
    echo "Available skills:"
    jq -r '.skills | keys[]' "$SKILL_RULES" | sed 's/^/  - /'
    exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📚 AUTO-LEARNING: Adding keywords to $SKILL_NAME"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Get existing keywords
EXISTING_KEYWORDS=$(jq -r ".skills[\"$SKILL_NAME\"].promptTriggers.keywords[]" "$SKILL_RULES" 2>/dev/null || echo "")

# Check which keywords are new
TRULY_NEW_KEYWORDS=()
for keyword in "${NEW_KEYWORDS[@]}"; do
    keyword_lower=$(echo "$keyword" | tr '[:upper:]' '[:lower:]')

    IS_DUPLICATE=false
    while IFS= read -r existing; do
        existing_lower=$(echo "$existing" | tr '[:upper:]' '[:lower:]')
        if [ "$keyword_lower" = "$existing_lower" ]; then
            IS_DUPLICATE=true
            echo "⏭️  Skipping '$keyword' (already exists)"
            break
        fi
    done <<< "$EXISTING_KEYWORDS"

    if [ "$IS_DUPLICATE" = false ]; then
        TRULY_NEW_KEYWORDS+=("$keyword")
        echo "✅ Adding '$keyword'"
    fi
done

# Exit if no new keywords
if [ ${#TRULY_NEW_KEYWORDS[@]} -eq 0 ]; then
    echo ""
    echo "ℹ️  No new keywords to add - all provided keywords already exist"
    exit 0
fi

echo ""
echo "Updating skill-rules.json..."

# Create backup
cp "$SKILL_RULES" "$SKILL_RULES.backup"

# Build jq update command
JQ_FILTER=".skills[\"$SKILL_NAME\"].promptTriggers.keywords += ["
for i in "${!TRULY_NEW_KEYWORDS[@]}"; do
    if [ $i -gt 0 ]; then
        JQ_FILTER+=", "
    fi
    JQ_FILTER+="\"${TRULY_NEW_KEYWORDS[$i]}\""
done
JQ_FILTER+="] | .skills[\"$SKILL_NAME\"].promptTriggers.keywords |= unique"

# Update skill-rules.json
jq "$JQ_FILTER" "$SKILL_RULES" > "$SKILL_RULES.tmp"

# Validate JSON
if jq empty "$SKILL_RULES.tmp" 2>/dev/null; then
    mv "$SKILL_RULES.tmp" "$SKILL_RULES"
    echo "✅ Updated skill-rules.json"

    # Remove backup
    rm "$SKILL_RULES.backup"

    # Log the update
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Added keywords to $SKILL_NAME" >> "$LOG_FILE"
    for keyword in "${TRULY_NEW_KEYWORDS[@]}"; do
        echo "  + $keyword" >> "$LOG_FILE"
    done
    echo "" >> "$LOG_FILE"

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✨ Success! Added ${#TRULY_NEW_KEYWORDS[@]} new keyword(s)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "💡 The system will now auto-activate '$SKILL_NAME' for prompts"
    echo "   containing these keywords."
    echo ""
else
    echo "❌ Error: Generated invalid JSON, restoring backup"
    mv "$SKILL_RULES.backup" "$SKILL_RULES"
    rm -f "$SKILL_RULES.tmp"
    exit 1
fi
