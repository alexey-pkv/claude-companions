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

1. Use Bash: `ls ~/.claude/tones/*.md 2>/dev/null | xargs -n1 basename | sed 's/\.md$//' | sort`
2. Display the results as a formatted list
3. Do NOT apply any tone — just show the list

### Path 2: Random tone selection

If `$ARGUMENTS` is "random":

1. Use Bash: `~/.claude/scripts/rotate-tone.sh`
2. Adopt the output as the tone for the rest of the session

### Path 3: Specific tone

If `$ARGUMENTS` is a tone name (e.g., "space-marine", "gordon-ramsay"):

1. Read `~/.claude/tones/$ARGUMENTS.md`
2. If found, confirm to the user which tone was loaded
3. Adopt the tone's communication style for the rest of the session

**If the tone is not found:**

1. Use Bash to list available tones: `ls ~/.claude/tones/*.md 2>/dev/null | xargs -n1 basename | sed 's/\.md$//' | sort`
2. Check if any available tone name is similar to what the user typed (e.g., "ramsay" → "gordon-ramsay", "marine" → "space-marine"). If there's a likely match, suggest it: "Did you mean `<tone-name>`?"
3. If no close match, show the available tones list and suggest: "You can create a custom tone with `/create-tone $ARGUMENTS`"

## After Loading a Tone

- Tell the user the tone name that was loaded
- Immediately begin using the tone's communication style
- Maintain the tone for all subsequent responses in the session
- The tone affects ONLY communication style — never compromise code quality, technical accuracy, or professionalism in code/architecture