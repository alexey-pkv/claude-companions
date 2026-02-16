#!/bin/bash
set -e
source "$(dirname "$0")/common.sh"

if [ -f "$SETTINGS" ]; then
    hook_cmd="$HOME/.claude/scripts/rotate-tone.sh"
    jq --arg cmd "$hook_cmd" \
        'if .hooks.SessionStart then .hooks.SessionStart = [.hooks.SessionStart[] | select(.hooks | map(select(.type == "command" and .command == $cmd)) | length == 0)] else . end | if .hooks.SessionStart == [] then del(.hooks.SessionStart) else . end | if .hooks == {} then del(.hooks) else . end' \
        "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
    echo "Removed SessionStart hook from settings"
fi

if [ -L "$CLAUDE_SCRIPTS/rotate-tone.sh" ]; then
    target=$(readlink "$CLAUDE_SCRIPTS/rotate-tone.sh")
    case "$target" in
        "$REPO_DIR"/*)
            rm "$CLAUDE_SCRIPTS/rotate-tone.sh"
            echo "Removed rotate-tone.sh symlink"
            ;;
        *)
            echo "Skipped: rotate-tone.sh is not managed by this repo"
            ;;
    esac
fi
