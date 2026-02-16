#!/bin/bash
# Shared variables and helpers for claude-tones scripts

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
REPO_TONES="$REPO_DIR/tones"
CLAUDE_DIR="$HOME/.claude"
CLAUDE_TONES="$HOME/.claude/tones"
CLAUDE_SKILLS="$HOME/.claude/skills"
CLAUDE_SCRIPTS="$HOME/.claude/scripts"
SETTINGS="$HOME/.claude/settings.json"

is_repo_symlink() {
    local file="$1"
    if [ -L "$file" ]; then
        target=$(readlink "$file")
        case "$target" in
            "$REPO_DIR"/*|"$REPO_TONES"/*) return 0 ;;
        esac
    fi
    return 1
}
