#!/bin/bash
set -e
source "$(dirname "$0")/common.sh"

install_single() {
    local name="$1"
    if [ ! -f "$REPO_TONES/$name.md" ]; then
        echo "Error: tone '$name' not found in $REPO_TONES/"
        exit 1
    fi
    mkdir -p "$CLAUDE_TONES"
    cp -f "$REPO_TONES/$name.md" "$CLAUDE_TONES/$name.md"
    echo "  Installed: $name"
}

install_all() {
    mkdir -p "$CLAUDE_TONES"
    count=0
    for f in "$REPO_TONES"/*.md; do
        [ -f "$f" ] || continue
        name=$(basename "$f" .md)
        cp -f "$f" "$CLAUDE_TONES/$name.md"
        echo "  Installed: $name"
        count=$((count + 1))
    done
    echo "Installed $count tone(s)"
}

if [ "$1" = "--all" ]; then
    install_all
elif [ -n "$1" ]; then
    install_single "$1"
    echo "Installed tone: $1"
else
    echo "Usage: install-tone.sh <name> | --all"
    exit 1
fi
