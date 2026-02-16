#!/bin/bash
set -e

TONES_DIR="$HOME/.claude/tones"

# Exit gracefully if tones directory doesn't exist
if [ ! -d "$TONES_DIR" ]; then
    exit 0
fi

# Get all .md files from tones directory into an array
TONE_FILES=("$TONES_DIR"/*.md)

# Exit gracefully if no tones exist
if [ ! -f "${TONE_FILES[0]}" ]; then
    exit 0
fi

# Randomly select one (macOS compatible)
SELECTED_FILE=$(printf '%s\n' "${TONE_FILES[@]}" | sort -R | head -n 1)
TONE_NAME=$(basename "$SELECTED_FILE" .md)

# Output the tone content to be injected into Claude's context
echo "🎭 Tone for this session: ${TONE_NAME}"
echo ""
cat "$SELECTED_FILE"
