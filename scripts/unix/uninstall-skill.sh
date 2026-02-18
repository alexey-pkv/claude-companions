#!/bin/bash
set -e
source "$(dirname "$0")/common.sh"

name="$1"
subdir="$2"

if [ -z "$name" ] || [ -z "$subdir" ]; then
    echo "Usage: uninstall-skill.sh <name> <subdir>"
    exit 1
fi

if [ -f "$CLAUDE_SKILLS/$subdir/SKILL.md" ]; then
    rm -rf "$CLAUDE_SKILLS/$subdir"
    echo "Removed $name skill"
else
    echo "Skill $name is not installed"
fi
