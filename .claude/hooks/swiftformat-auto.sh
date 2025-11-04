#!/bin/bash

# SwiftFormat Auto-Formatter Hook (Stop Event)
# Automatically formats Swift files after Claude finishes responding
#
# ⚠️  WARNING - CONTEXT TOKEN USAGE CONCERN ⚠️
# Based on research from https://github.com/diet103/claude-code-infrastructure-showcase
# and community feedback:
#
# File modifications trigger <system-reminder> notifications that consume context tokens.
# In some cases, auto-formatting can lead to significant token usage:
# - Large files with many formatting changes = more tokens consumed
# - Strict formatting rules = more changes = more tokens
# - Each file change generates a system-reminder with full diff context
#
# RECOMMENDATION:
# - Monitor your context usage after enabling this hook
# - If you notice rapid context depletion, consider disabling this hook
# - Alternative: Run SwiftFormat manually between Claude sessions instead
#
# TO DISABLE THIS HOOK:
# 1. Rename this file to add .disabled extension: swiftformat-auto.sh.disabled
# 2. Or delete this file entirely
#
# Based on: https://github.com/diet103/claude-code-infrastructure-showcase

set -euo pipefail

# Configuration
ENABLED=true  # Set to false to disable without deleting the file
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/../logs"
TOOL_LOG="$LOG_DIR/tool-usage.log"
FORMAT_LOG="$LOG_DIR/swiftformat.log"

# Exit if disabled
if [ "$ENABLED" != "true" ]; then
    exit 0
fi

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Check if SwiftFormat is installed
if ! command -v swiftformat &> /dev/null; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] SwiftFormat not installed. Skipping auto-format." >> "$FORMAT_LOG"
    exit 0
fi

# Check if tool usage log exists
if [ ! -f "$TOOL_LOG" ]; then
    exit 0
fi

# Get timestamp for this run
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Extract Swift files that were edited in the last minute
# (Stop hook runs after Claude finishes, so recent edits are relevant)
SWIFT_FILES=$(grep -E "\.(swift|Swift)" "$TOOL_LOG" 2>/dev/null | \
              tail -20 | \
              grep -oE '[^ ]+\.swift' | \
              sort -u || true)

# If no Swift files, exit
if [ -z "$SWIFT_FILES" ]; then
    exit 0
fi

# Log formatting session
echo "[$TIMESTAMP] Auto-formatting Swift files..." >> "$FORMAT_LOG"

# Format each Swift file
FORMATTED_COUNT=0
while IFS= read -r file; do
    # Skip if file doesn't exist (might have been deleted)
    if [ ! -f "$file" ]; then
        continue
    fi

    # Run SwiftFormat
    if swiftformat "$file" --quiet 2>/dev/null; then
        echo "  ✓ Formatted: $file" >> "$FORMAT_LOG"
        ((FORMATTED_COUNT++))
    else
        echo "  ✗ Failed: $file" >> "$FORMAT_LOG"
    fi
done <<< "$SWIFT_FILES"

# Log summary
if [ $FORMATTED_COUNT -gt 0 ]; then
    echo "  Summary: Formatted $FORMATTED_COUNT Swift file(s)" >> "$FORMAT_LOG"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✨ SwiftFormat Auto-Formatter"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Automatically formatted $FORMATTED_COUNT Swift file(s)"
    echo ""
    echo "⚠️  Note: File formatting consumes context tokens via <system-reminder> diffs."
    echo "   If context usage is too high, disable this hook by setting ENABLED=false"
    echo "   in .claude/hooks/swiftformat-auto.sh"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
fi

exit 0
