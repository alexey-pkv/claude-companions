---
name: tone
description: This skill should be used when the user asks to "change tone", "switch tone", "random tone", "list tones", "set tone", "/tone", or mentions wanting a different communication style or personality for the session.
disable-model-invocation: true
---

# Tone Selection

Switch or randomize the communication tone/personality for the current session. Tones are stored as `.md` files in `~/.claude/tones/`.

## Handling Arguments

Parse `$ARGUMENTS` and follow one of three paths:

### Path 1: List available tones

If `$ARGUMENTS` is empty, not provided, "list", or "ls":

1. Use Glob to find all `*.md` files in `~/.claude/tones/`
2. Extract the filename without `.md` extension for each
3. Display as a formatted list, sorted alphabetically
4. Do NOT apply any tone — just show the list

### Path 2: Random tone selection

If `$ARGUMENTS` is "random":

1. Use Glob to find all `*.md` files in `~/.claude/tones/`
2. Use Bash to randomly pick one: `ls ~/.claude/tones/*.md | sort -R | head -n 1`
3. Read the selected tone file
4. Confirm to the user which tone was selected
5. Adopt the tone's communication style for the rest of the session

### Path 3: Specific tone

If `$ARGUMENTS` is a tone name (e.g., "space-marine", "gordon-ramsay"):

1. Read `~/.claude/tones/$ARGUMENTS.md`
2. If the file does not exist, inform the user and list available tones
3. If found, confirm to the user which tone was loaded
4. Adopt the tone's communication style for the rest of the session

## After Loading a Tone

- Tell the user the tone name that was loaded
- Immediately begin using the tone's communication style
- Maintain the tone for all subsequent responses in the session
- The tone affects ONLY communication style — never compromise code quality, technical accuracy, or professionalism in code/architecture
