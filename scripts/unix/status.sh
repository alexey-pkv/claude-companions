#!/bin/bash
set -e
source "$(dirname "$0")/common.sh"

echo "claude-tones status"
echo "==================="

installed=0; local_count=0
if [ -d "$CLAUDE_TONES" ]; then
    for f in "$CLAUDE_TONES"/*.md; do
        [ -f "$f" ] || continue
        if [ -L "$f" ]; then
            target=$(readlink "$f")
            case "$target" in
                "$REPO_TONES"/*) installed=$((installed + 1)) ;;
                *) local_count=$((local_count + 1)) ;;
            esac
        else
            local_count=$((local_count + 1))
        fi
    done
fi
echo "Tones installed: $installed"
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

if [ -L "$CLAUDE_SKILLS/tone/SKILL.md" ]; then
    target=$(readlink "$CLAUDE_SKILLS/tone/SKILL.md")
    case "$target" in
        "$REPO_DIR"/*) echo "/tone skill:     installed" ;;
        *) echo "/tone skill:     not installed" ;;
    esac
else
    echo "/tone skill:     not installed"
fi

if [ -L "$CLAUDE_SKILLS/create-tone/SKILL.md" ]; then
    target=$(readlink "$CLAUDE_SKILLS/create-tone/SKILL.md")
    case "$target" in
        "$REPO_DIR"/*) echo "/create-tone skill: installed" ;;
        *) echo "/create-tone skill: not installed" ;;
    esac
else
    echo "/create-tone skill: not installed"
fi
