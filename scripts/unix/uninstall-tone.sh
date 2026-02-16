#!/bin/bash
set -e
source "$(dirname "$0")/common.sh"

uninstall_single() {
    local name="$1"
    if [ -L "$CLAUDE_TONES/$name.md" ]; then
        target=$(readlink "$CLAUDE_TONES/$name.md")
        case "$target" in
            "$REPO_TONES"/*)
                rm "$CLAUDE_TONES/$name.md"
                echo "Uninstalled tone: $name"
                ;;
            *)
                echo "Skipped: $name is not managed by this repo"
                ;;
        esac
    else
        echo "Tone '$name' is not installed as a symlink"
    fi
}

uninstall_all() {
    count=0
    if [ -d "$CLAUDE_TONES" ]; then
        for f in "$CLAUDE_TONES"/*.md; do
            [ -f "$f" ] || continue
            if [ -L "$f" ]; then
                target=$(readlink "$f")
                case "$target" in
                    "$REPO_TONES"/*)
                        rm "$f"
                        echo "  Removed: $(basename "$f" .md)"
                        count=$((count + 1))
                        ;;
                esac
            fi
        done
    fi
    echo "Uninstalled $count tone(s)"
}

if [ "$1" = "--all" ]; then
    uninstall_all
elif [ -n "$1" ]; then
    uninstall_single "$1"
else
    echo "Usage: uninstall-tone.sh <name> | --all"
    exit 1
fi
