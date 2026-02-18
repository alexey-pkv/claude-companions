# Claude Companions — Installation Guide

This repo contains a library of communication tones for Claude Code. When a user asks to install, set up, or configure tones, follow this guide.

## Installation

When the user asks to install (e.g., "install tones", "set up tones", "configure tones"), determine what they want:

### 1. Predefined Tones
- **All tones**: `make install-tones`
- **Specific tones**: `make install-tone TONE=<name>` for each
- **None**: Skip

### 2. Session-Start Trigger (random tone each session)
- **Yes**: `make install-hook`
- **No**: Skip

### 3. /tone Command (change/list/random tones mid-session)
- **Yes**: `make install-tone-skill`
- **No**: Skip

### 4. /create-tone Skill (generate new custom tones)
- **Yes**: `make install-create-skill`
- **No**: Skip

### Quick Install
- **Everything**: `make install-all`

### Interpreting Natural Language
- "install without trigger" → install-tones + skills, skip hook
- "just give me gordon-ramsay and churchill" → `make install-tone TONE=gordon-ramsay && make install-tone TONE=churchill`
- "install everything" → `make install-all`
- "just the commands" → install skills only, skip tones and hook

### Platform Detection
- **macOS/Linux**: Use `make` targets
- **Windows**: Use PowerShell scripts: `.\scripts\windows\install.ps1 -All` or with switches: `-Tones`, `-Hook`, `-ToneSkill`, `-CreateSkill`, `-Tone <name>`

## Uninstall

- **Everything**: `make uninstall`
- **Just tones**: `make uninstall-tones`
- **Specific tone**: `make uninstall-tone TONE=<name>`
- **Windows**: `.\scripts\windows\uninstall.ps1 -All` or with individual switches

## Update

- `make update` — pulls latest, shows what's new/changed, suggests installing new tones

## Status

- `make status` — shows what's currently installed

## Listing Tones

- `make list` — shows all tones with their status (installed/available/local)
