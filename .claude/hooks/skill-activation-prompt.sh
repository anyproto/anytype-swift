#!/bin/bash

# Skill Auto-Activation Hook (UserPromptSubmit)
# This hook analyzes user prompts and suggests relevant skills automatically
# Based on: https://github.com/diet103/claude-code-infrastructure-showcase

set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_RULES="$SCRIPT_DIR/skill-rules.json"
LOG_DIR="$SCRIPT_DIR/../logs"
LOG_FILE="$LOG_DIR/skill-activations.log"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Read event data from stdin
EVENT_DATA=$(cat)

# Extract user prompt from event data
USER_PROMPT=$(echo "$EVENT_DATA" | jq -r '.prompt // empty')

# Exit silently if no prompt
if [ -z "$USER_PROMPT" ]; then
    exit 0
fi

# Log timestamp
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Analyzing prompt..." >> "$LOG_FILE"

# Convert prompt to lowercase for case-insensitive matching
PROMPT_LOWER=$(echo "$USER_PROMPT" | tr '[:upper:]' '[:lower:]')

# Array to hold matched skills
MATCHED_SKILLS=()

# Function to check if prompt contains any keyword
contains_keyword() {
    local skill_name=$1
    local keywords=$(jq -r ".skills[\"$skill_name\"].promptTriggers.keywords[]" "$SKILL_RULES")

    while IFS= read -r keyword; do
        keyword_lower=$(echo "$keyword" | tr '[:upper:]' '[:lower:]')
        if echo "$PROMPT_LOWER" | grep -qi "$keyword_lower"; then
            return 0  # Found match
        fi
    done <<< "$keywords"

    return 1  # No match
}

# Function to check if prompt matches any intent pattern
matches_intent() {
    local skill_name=$1
    local patterns=$(jq -r ".skills[\"$skill_name\"].promptTriggers.intentPatterns[]" "$SKILL_RULES" 2>/dev/null)

    if [ -z "$patterns" ]; then
        return 1
    fi

    while IFS= read -r pattern; do
        if echo "$PROMPT_LOWER" | grep -qiE "$pattern"; then
            return 0  # Found match
        fi
    done <<< "$patterns"

    return 1  # No match
}

# Check each skill for matches
for skill in $(jq -r '.skills | keys[]' "$SKILL_RULES"); do
    if contains_keyword "$skill" || matches_intent "$skill"; then
        MATCHED_SKILLS+=("$skill")
        echo "  ✓ Matched: $skill" >> "$LOG_FILE"
    fi
done

# If no skills matched, exit silently
if [ ${#MATCHED_SKILLS[@]} -eq 0 ]; then
    echo "  No skills matched" >> "$LOG_FILE"
    exit 0
fi

# Get max skills per prompt from config (default: 2)
MAX_SKILLS=$(jq -r '.config.maxSkillsPerPrompt // 2' "$SKILL_RULES")

# Limit to max skills
if [ ${#MATCHED_SKILLS[@]} -gt $MAX_SKILLS ]; then
    MATCHED_SKILLS=("${MATCHED_SKILLS[@]:0:$MAX_SKILLS}")
fi

# Build skill activation message
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎯 SKILL ACTIVATION CHECK"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

for skill in "${MATCHED_SKILLS[@]}"; do
    description=$(jq -r ".skills[\"$skill\"].description" "$SKILL_RULES")
    echo "📚 Relevant Skill: $skill"
    echo "   Description: $description"
    echo ""
done

echo "💡 Consider using these skills if they're relevant to this task."
echo "   You can manually load a skill by reading its SKILL.md file."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Log successful activation
echo "  Suggested skills: ${MATCHED_SKILLS[*]}" >> "$LOG_FILE"

exit 0
