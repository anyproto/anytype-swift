#!/bin/bash

# Keyword Extraction Utility
# Extracts relevant technical keywords from a user prompt for skill auto-learning

set -euo pipefail

# Read prompt from argument or stdin
if [ $# -eq 0 ]; then
    PROMPT=$(cat)
else
    PROMPT="$1"
fi

# Convert to lowercase
PROMPT_LOWER=$(echo "$PROMPT" | tr '[:upper:]' '[:lower:]')

# Common stopwords to exclude
STOPWORDS="the a an and or but in on at to for of with by from as is was are were be been being have has had do does did will would should could may might must can this that these those i you he she it we they my your his her its our their me him them what which who when where why how all each every both few more most other some such no nor not only own same so than too very just now need want like get make go see"

# Extract words (alphanumeric + hyphens + dots)
WORDS=$(echo "$PROMPT_LOWER" | grep -oE '[a-z0-9][a-z0-9._-]*' | sort -u)

# Filter and score words
SCORED_WORDS=""

for word in $WORDS; do
    # Skip short words
    if [ ${#word} -lt 3 ]; then
        continue
    fi

    # Skip if stopword
    if echo " $STOPWORDS " | grep -q " $word "; then
        continue
    fi

    # Calculate score
    score=1

    # Boost technical terms
    if echo "$word" | grep -qE '^(view|model|controller|coordinator|service|repository|manager|handler)'; then
        score=$((score + 3))
    fi

    # Boost Swift/iOS terms
    if echo "$word" | grep -qE '^(swift|swiftui|combine|async|await|observable|published)'; then
        score=$((score + 3))
    fi

    # Boost file extensions
    if echo "$word" | grep -qE '\.(swift|xcstrings|yml|md)$'; then
        score=$((score + 2))
    fi

    # Boost compound technical words
    if echo "$word" | grep -qE '[_.]'; then
        score=$((score + 2))
    fi

    # Boost longer words
    if [ ${#word} -gt 8 ]; then
        score=$((score + 1))
    fi

    # Store as "score word"
    SCORED_WORDS="$SCORED_WORDS
$score $word"
done

# Sort by score (descending) and take top 5
echo "$SCORED_WORDS" | grep -v '^$' | sort -rn | head -5 | awk '{print $2}'
