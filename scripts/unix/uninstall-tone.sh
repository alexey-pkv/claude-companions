#!/bin/bash
set -e
source "$(dirname "$0")/common.sh"

uninstall_single() {
    local name="$1"
    if [ -f "$CLAUDE_TONES/$name.md" ]; then
        rm "$CLAUDE_TONES/$name.md"
        echo "Uninstalled tone: $name"
    else
        echo "Tone '$name' is not installed"
    fi
}

uninstall_all() {
    if [ -d "$CLAUDE_TONES" ]; then
        rm -rf "$CLAUDE_TONES"
        echo "Removed all tones"
    else
        echo "No tones installed"
    fi
}

if [ "$1" = "--all" ]; then
    uninstall_all
elif [ -n "$1" ]; then
    uninstall_single "$1"
else
    echo "Usage: uninstall-tone.sh <name> | --all"
    exit 1
fi
