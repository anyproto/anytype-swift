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

# Validate EVENT_DATA is valid JSON before parsing
if ! echo "$EVENT_DATA" | jq -e . >/dev/null 2>&1; then
    exit 0
fi

# Extract user prompt from event data
USER_PROMPT=$(echo "$EVENT_DATA" | jq -r '.prompt // empty' 2>/dev/null)

# Exit silently if no prompt
if [ -z "$USER_PROMPT" ]; then
    exit 0
fi

# Log timestamp
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Analyzing prompt..." >> "$LOG_FILE"

# Convert prompt to lowercase for case-insensitive matching
PROMPT_LOWER=$(echo "$USER_PROMPT" | tr '[:upper:]' '[:lower:]')

# Arrays to hold matched skills and their scores (parallel arrays for bash 3.2 compatibility)
MATCHED_SKILLS=()
MATCHED_SCORES=()

# Load scoring configuration from skill-rules.json (with defaults)
KEYWORD_WEIGHT=$(jq -r '.config.scoring.keywordWeight // 2' "$SKILL_RULES")
INTENT_WEIGHT=$(jq -r '.config.scoring.intentWeight // 3' "$SKILL_RULES")
CONFIDENCE_THRESHOLD=$(jq -r '.config.scoring.confidenceThreshold // 3' "$SKILL_RULES")
HIGH_CONFIDENCE=$(jq -r '.config.scoring.highConfidenceScore // 6' "$SKILL_RULES")
MEDIUM_CONFIDENCE=$(jq -r '.config.scoring.mediumConfidenceScore // 4' "$SKILL_RULES")

# Function to count keyword matches (returns count via global variable)
KEYWORD_MATCH_COUNT=0
count_keyword_matches() {
    local skill_name=$1
    KEYWORD_MATCH_COUNT=0
    local keywords=$(jq -r --arg name "$skill_name" '.skills[$name].promptTriggers.keywords[]' "$SKILL_RULES" 2>/dev/null)

    while IFS= read -r keyword; do
        if [ -n "$keyword" ]; then
            keyword_lower=$(echo "$keyword" | tr '[:upper:]' '[:lower:]')
            if echo "$PROMPT_LOWER" | grep -qi "$keyword_lower"; then
                ((KEYWORD_MATCH_COUNT++)) || true
            fi
        fi
    done <<< "$keywords"
}

# Function to check if prompt contains any keyword (for backwards compatibility)
contains_keyword() {
    local skill_name=$1
    count_keyword_matches "$skill_name"
    [ $KEYWORD_MATCH_COUNT -gt 0 ]
}

# Function to count intent pattern matches (returns count via global variable)
INTENT_MATCH_COUNT=0
count_intent_matches() {
    local skill_name=$1
    INTENT_MATCH_COUNT=0
    local patterns=$(jq -r --arg name "$skill_name" '.skills[$name].promptTriggers.intentPatterns[]' "$SKILL_RULES" 2>/dev/null)

    if [ -z "$patterns" ]; then
        return
    fi

    while IFS= read -r pattern; do
        if [ -n "$pattern" ]; then
            if echo "$PROMPT_LOWER" | grep -qiE "$pattern"; then
                ((INTENT_MATCH_COUNT++)) || true
            fi
        fi
    done <<< "$patterns"
}

# Function to check if prompt matches any intent pattern (for backwards compatibility)
matches_intent() {
    local skill_name=$1
    count_intent_matches "$skill_name"
    [ $INTENT_MATCH_COUNT -gt 0 ]
}

# Function to check if prompt matches any exclusion pattern
matches_exclusion() {
    local skill_name=$1
    local patterns=$(jq -r --arg name "$skill_name" '.skills[$name].promptTriggers.excludePatterns[]?' "$SKILL_RULES" 2>/dev/null)

    if [ -z "$patterns" ]; then
        return 1  # No exclusions defined
    fi

    while IFS= read -r pattern; do
        if [ -n "$pattern" ]; then
            pattern_lower=$(echo "$pattern" | tr '[:upper:]' '[:lower:]')
            if echo "$PROMPT_LOWER" | grep -qiF "$pattern_lower"; then
                return 0  # Found exclusion match - should exclude
            fi
        fi
    done <<< "$patterns"

    return 1  # No exclusion match
}

# Check each skill for matches with scoring
while IFS= read -r skill; do
    [ -z "$skill" ] && continue
    # Count matches
    count_keyword_matches "$skill"
    count_intent_matches "$skill"

    # Calculate score
    SCORE=$((KEYWORD_MATCH_COUNT * KEYWORD_WEIGHT + INTENT_MATCH_COUNT * INTENT_WEIGHT))

    if [ $SCORE -gt 0 ]; then
        # Check if any exclusion pattern matches - skip if so
        if matches_exclusion "$skill"; then
            echo "  ✗ Excluded: $skill (score=$SCORE, matched exclusion pattern)" >> "$LOG_FILE"
            continue
        fi

        # Check confidence threshold
        if [ $SCORE -ge $CONFIDENCE_THRESHOLD ]; then
            MATCHED_SKILLS+=("$skill")
            MATCHED_SCORES+=("$SCORE")
            echo "  ✓ Matched: $skill (score=$SCORE, keywords=$KEYWORD_MATCH_COUNT, intents=$INTENT_MATCH_COUNT)" >> "$LOG_FILE"
        else
            echo "  ○ Below threshold: $skill (score=$SCORE < $CONFIDENCE_THRESHOLD)" >> "$LOG_FILE"
        fi
    fi
done < <(jq -r '.skills | keys[]' "$SKILL_RULES")

# Sort matched skills by score (highest first) using parallel arrays
if [ ${#MATCHED_SKILLS[@]} -gt 1 ]; then
    # Create array of "score:index" pairs for sorting
    SORT_INPUT=()
    for i in "${!MATCHED_SKILLS[@]}"; do
        SORT_INPUT+=("${MATCHED_SCORES[$i]}:$i")
    done

    # Sort and rebuild arrays
    SORTED_SKILLS=()
    SORTED_SCORES=()
    while IFS=: read -r score idx; do
        if [ -n "$idx" ]; then
            SORTED_SKILLS+=("${MATCHED_SKILLS[$idx]}")
            SORTED_SCORES+=("$score")
        fi
    done < <(printf '%s\n' "${SORT_INPUT[@]}" | sort -t: -k1 -rn)

    MATCHED_SKILLS=("${SORTED_SKILLS[@]}")
    MATCHED_SCORES=("${SORTED_SCORES[@]}")
fi

# If no skills matched, check if prompt is substantial
if [ ${#MATCHED_SKILLS[@]} -eq 0 ]; then
    echo "  No skills matched" >> "$LOG_FILE"

    # Calculate prompt size metrics
    CHAR_COUNT=${#USER_PROMPT}
    LINE_COUNT=$(echo "$USER_PROMPT" | wc -l | tr -d ' ')

    # Threshold: 100+ characters OR 3+ lines
    if [ $CHAR_COUNT -ge 100 ] || [ $LINE_COUNT -ge 3 ]; then
        echo "  Substantial prompt (${CHAR_COUNT} chars, ${LINE_COUNT} lines) - prompting user" >> "$LOG_FILE"

        # Log to missed activations file
        MISSED_LOG="$LOG_DIR/skill-activations-missed.log"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Missed activation" >> "$MISSED_LOG"
        echo "  Prompt: ${USER_PROMPT:0:200}..." >> "$MISSED_LOG"
        echo "  Size: ${CHAR_COUNT} chars, ${LINE_COUNT} lines" >> "$MISSED_LOG"
        echo "" >> "$MISSED_LOG"

        # Build skill list for user
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "💡 NO SKILLS ACTIVATED"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "Your prompt seems substantial (${CHAR_COUNT} chars, ${LINE_COUNT} lines) but no skills matched."
        echo ""
        echo "📚 Available skills:"
        echo ""

        # List all skills
        while IFS= read -r skill; do
            [ -z "$skill" ] && continue
            description=$(jq -r --arg name "$skill" '.skills[$name].description' "$SKILL_RULES")
            printf '   • %s\n' "$skill"
            printf '     %s\n' "$description"
            echo ""
        done < <(jq -r '.skills | keys[]' "$SKILL_RULES")

        echo "❓ Should any of these skills be activated for this task?"
        echo "   If yes, tell me which one and I'll extract keywords from your prompt"
        echo "   to improve future auto-activation."
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
    fi

    exit 0
fi

# Get max skills per prompt from config (default: 2)
MAX_SKILLS=$(jq -r '.config.maxSkillsPerPrompt // 2' "$SKILL_RULES")

# Store all matched skills before limiting
ALL_MATCHED_SKILLS=("${MATCHED_SKILLS[@]}")
ALL_MATCHED_SCORES=("${MATCHED_SCORES[@]}")

# Limit displayed skills to max
DISPLAY_SKILLS=("${MATCHED_SKILLS[@]:0:$MAX_SKILLS}")
DISPLAY_SCORES=("${MATCHED_SCORES[@]:0:$MAX_SKILLS}")

# Get cut-off skills (those beyond the limit)
CUTOFF_SKILLS=()
CUTOFF_SCORES=()
if [ ${#ALL_MATCHED_SKILLS[@]} -gt $MAX_SKILLS ]; then
    CUTOFF_SKILLS=("${ALL_MATCHED_SKILLS[@]:$MAX_SKILLS}")
    CUTOFF_SCORES=("${ALL_MATCHED_SCORES[@]:$MAX_SKILLS}")
fi

# Use display arrays for output
MATCHED_SKILLS=("${DISPLAY_SKILLS[@]}")
MATCHED_SCORES=("${DISPLAY_SCORES[@]}")

# Build skill activation message
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎯 SKILL ACTIVATION CHECK"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

for i in "${!MATCHED_SKILLS[@]}"; do
    skill="${MATCHED_SKILLS[$i]}"
    score="${MATCHED_SCORES[$i]}"
    description=$(jq -r --arg name "$skill" '.skills[$name].description' "$SKILL_RULES")
    related=$(jq -r --arg name "$skill" '.skills[$name].relatedSkills // [] | join(", ")' "$SKILL_RULES")

    # Determine confidence level (using configurable thresholds)
    if [ "$score" -ge "$HIGH_CONFIDENCE" ]; then
        confidence="HIGH"
        emoji="🟢"
    elif [ "$score" -ge "$MEDIUM_CONFIDENCE" ]; then
        confidence="MEDIUM"
        emoji="🟡"
    else
        confidence="LOW"
        emoji="🟠"
    fi

    printf '📚 Relevant Skill: %s\n' "$skill"
    printf '   Description: %s\n' "$description"
    printf '   Confidence: %s %s (score: %s)\n' "$emoji" "$confidence" "$score"
    if [ -n "$related" ]; then
        printf '   Related: %s\n' "$related"
    fi
    echo ""
done

# Show cut-off skills if any
if [ ${#CUTOFF_SKILLS[@]} -gt 0 ]; then
    echo "📋 Also matched (not shown above):"
    for i in "${!CUTOFF_SKILLS[@]}"; do
        skill="${CUTOFF_SKILLS[$i]}"
        score="${CUTOFF_SCORES[$i]}"
        printf '   • %s (score: %s)\n' "$skill" "$score"
    done
    echo ""
fi

echo "💡 Consider using these skills if they're relevant to this task."
echo "   You can manually load a skill by reading its SKILL.md file."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Log successful activation
echo "  Suggested skills: ${ALL_MATCHED_SKILLS[*]}" >> "$LOG_FILE"

exit 0
