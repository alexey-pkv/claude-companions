#!/bin/bash
set -e
source "$(dirname "$0")/common.sh"

name="$1"
subdir="$2"

if [ -z "$name" ] || [ -z "$subdir" ]; then
    echo "Usage: install-skill.sh <name> <subdir>"
    exit 1
fi

mkdir -p "$CLAUDE_SKILLS/$subdir"
ln -sf "$REPO_DIR/skills/$subdir/SKILL.md" "$CLAUDE_SKILLS/$subdir/SKILL.md"
echo "Installed $name skill"
