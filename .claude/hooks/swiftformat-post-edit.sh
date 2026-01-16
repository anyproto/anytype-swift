#!/bin/bash
# SwiftFormat PostToolUse Hook - formats Swift files immediately after edit
# Based on Boris Cherny's workflow pattern

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/../logs"
LOG_FILE="$LOG_DIR/swiftformat.log"
mkdir -p "$LOG_DIR"

# Read event data
EVENT_DATA=$(cat)

# Extract file path
TOOL_NAME=$(echo "$EVENT_DATA" | jq -r '.tool // "unknown"')
FILE_PATH=""

case "$TOOL_NAME" in
    Edit|Write)
        FILE_PATH=$(echo "$EVENT_DATA" | jq -r '.parameters.file_path // empty')
        ;;
    *)
        exit 0
        ;;
esac

# Only process .swift files
if [[ ! "$FILE_PATH" =~ \.swift$ ]]; then
    exit 0
fi

# Skip if file doesn't exist
if [ ! -f "$FILE_PATH" ]; then
    exit 0
fi

# Check if SwiftFormat is installed
if ! command -v swiftformat &> /dev/null; then
    exit 0
fi

# Format the file (quiet, no output to minimize token usage)
if swiftformat "$FILE_PATH" --quiet 2>/dev/null; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Formatted: $FILE_PATH" >> "$LOG_FILE"
fi

exit 0
