#!/bin/bash
set -e
source "$(dirname "$0")/common.sh"

mkdir -p "$CLAUDE_SCRIPTS"
ln -sf "$REPO_DIR/scripts/unix/rotate-tone.sh" "$CLAUDE_SCRIPTS/rotate-tone.sh"
chmod +x "$CLAUDE_SCRIPTS/rotate-tone.sh"

mkdir -p "$CLAUDE_DIR"
if [ ! -f "$SETTINGS" ]; then
    echo '{}' > "$SETTINGS"
fi

hook_cmd="$HOME/.claude/scripts/rotate-tone.sh"
has_hook=$(jq -r \
    --arg cmd "$hook_cmd" \
    '.hooks.SessionStart // [] | map(.hooks // [] | map(select(.type == "command" and .command == $cmd))) | flatten | length' \
    "$SETTINGS" 2>/dev/null || echo "0")

if [ "$has_hook" != "0" ] && [ "$has_hook" != "" ]; then
    echo "Hook already installed"
else
    jq --arg cmd "$hook_cmd" \
        '.hooks.SessionStart = ((.hooks.SessionStart // []) + [{"hooks": [{"type": "command", "command": $cmd}]}])' \
        "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
    echo "Installed SessionStart hook"
fi
