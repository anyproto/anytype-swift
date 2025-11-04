#!/bin/bash

# Post-Tool-Use Tracker Hook
# Logs all Edit/Write/MultiEdit operations for monitoring and debugging
# Based on: https://github.com/diet103/claude-code-infrastructure-showcase

set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/../logs"
LOG_FILE="$LOG_DIR/tool-usage.log"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Read event data from stdin
EVENT_DATA=$(cat)

# Extract tool name and parameters
TOOL_NAME=$(echo "$EVENT_DATA" | jq -r '.tool // "unknown"')

# Only track file modification tools
case "$TOOL_NAME" in
    Edit|Write|MultiEdit|NotebookEdit)
        ;;
    *)
        # Not a file modification tool, exit silently
        exit 0
        ;;
esac

# Get timestamp
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Extract file path(s) based on tool type
FILE_PATHS=""

case "$TOOL_NAME" in
    Edit|Write|NotebookEdit)
        FILE_PATH=$(echo "$EVENT_DATA" | jq -r '.parameters.file_path // .parameters.notebook_path // "unknown"')
        FILE_PATHS="$FILE_PATH"
        ;;
    MultiEdit)
        # MultiEdit has an array of edits
        FILE_PATHS=$(echo "$EVENT_DATA" | jq -r '.parameters.edits[]?.file_path // empty' | tr '\n' ', ' | sed 's/,$//')
        ;;
esac

# If no files found, exit
if [ -z "$FILE_PATHS" ]; then
    exit 0
fi

# Log the tool usage
echo "[$TIMESTAMP] $TOOL_NAME: $FILE_PATHS" >> "$LOG_FILE"

# Extract repo/directory context (helps identify which part of the project was modified)
for file in $(echo "$FILE_PATHS" | tr ',' '\n'); do
    # Remove leading/trailing whitespace
    file=$(echo "$file" | xargs)

    # Determine which area of the codebase
    AREA="unknown"
    if echo "$file" | grep -q "PresentationLayer"; then
        AREA="UI/Presentation"
    elif echo "$file" | grep -q "ServiceLayer"; then
        AREA="Services"
    elif echo "$file" | grep -q "ApplicationLayer"; then
        AREA="Application"
    elif echo "$file" | grep -q "Models"; then
        AREA="Models"
    elif echo "$file" | grep -q "\.claude/"; then
        AREA="Claude Config"
    elif echo "$file" | grep -q "Modules/"; then
        AREA="Modules"
    elif echo "$file" | grep -q "\.xcstrings"; then
        AREA="Localization"
    fi

    echo "  └─ Area: $AREA, File: $file" >> "$LOG_FILE"
done

exit 0
