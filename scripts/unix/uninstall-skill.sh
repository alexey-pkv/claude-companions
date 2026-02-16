#!/bin/bash
set -e
source "$(dirname "$0")/common.sh"

name="$1"
subdir="$2"

if [ -z "$name" ] || [ -z "$subdir" ]; then
    echo "Usage: uninstall-skill.sh <name> <subdir>"
    exit 1
fi

if [ -L "$CLAUDE_SKILLS/$subdir/SKILL.md" ]; then
    target=$(readlink "$CLAUDE_SKILLS/$subdir/SKILL.md")
    case "$target" in
        "$REPO_DIR"/*)
            rm "$CLAUDE_SKILLS/$subdir/SKILL.md"
            echo "Removed $name skill"
            ;;
    esac
fi
