#!/bin/bash
# Shared variables for claude-tones scripts

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
REPO_TONES="$REPO_DIR/tones"
CLAUDE_DIR="$HOME/.claude"
CLAUDE_TONES="$HOME/.claude/tones"
CLAUDE_SKILLS="$HOME/.claude/skills"
CLAUDE_SCRIPTS="$HOME/.claude/scripts"
SETTINGS="$HOME/.claude/settings.json"
