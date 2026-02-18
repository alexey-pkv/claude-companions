#!/bin/bash
set -e
source "$(dirname "$0")/common.sh"

echo "claude-tones status"
echo "==================="

installed=0; modified=0; local_count=0
if [ -d "$CLAUDE_TONES" ]; then
    for f in "$CLAUDE_TONES"/*.md; do
        [ -f "$f" ] || continue
        name=$(basename "$f" .md)
        if [ -f "$REPO_TONES/$name.md" ]; then
            if cmp -s "$f" "$REPO_TONES/$name.md"; then
                installed=$((installed + 1))
            else
                modified=$((modified + 1))
            fi
        else
            local_count=$((local_count + 1))
        fi
    done
fi
echo "Tones installed: $installed"
echo "Tones modified:  $modified"
echo "Tones local:     $local_count"

if [ -f "$SETTINGS" ]; then
    hook_cmd="$HOME/.claude/scripts/rotate-tone.sh"
    has_hook=$(jq -r \
        --arg cmd "$hook_cmd" \
        '.hooks.SessionStart // [] | map(.hooks // [] | map(select(.type == "command" and .command == $cmd))) | flatten | length' \
        "$SETTINGS" 2>/dev/null || echo "0")
    if [ "$has_hook" != "0" ] && [ "$has_hook" != "" ]; then
        echo "Hook:            installed"
    else
        echo "Hook:            not installed"
    fi
else
    echo "Hook:            not installed"
fi

if [ -f "$CLAUDE_SKILLS/tone/SKILL.md" ]; then
    echo "/tone skill:     installed"
else
    echo "/tone skill:     not installed"
fi

if [ -f "$CLAUDE_SKILLS/create-tone/SKILL.md" ]; then
    echo "/create-tone skill: installed"
else
    echo "/create-tone skill: not installed"
fi
