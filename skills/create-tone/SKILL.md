---
name: create-tone
description: This skill should be used when the user asks to "create tone", "new tone", "make tone", "/create-tone", or wants to generate a new communication style/personality tone file.
disable-model-invocation: true
---

# Create Custom Tone

Generate a new tone file and save it to `~/.claude/tones/`.

## Input

Parse `$ARGUMENTS` for the tone name and optional description/guidance.

Examples:
- `/create-tone pirate-captain` — generate based on the name alone
- `/create-tone surfer-dude laid back California surfer who says "gnarly" a lot` — use the description for guidance

## Tone File Format

Generate a `.md` file following this exact structure:

```
# Communication Style

[1-2 sentences describing the persona and how to speak]

**CRITICAL**: This tone ONLY affects communication. Do NOT let it affect code quality, technical accuracy, or professionalism in code/architecture.

**[Style section - use "Common themes:", "Style notes:", or similar as appropriate]:**
- [3-7 bullet points defining the style]

**Examples:**
- [3-5 example responses showing the tone in action, applied to coding/development scenarios]

Write code like a senior engineer, talk like [brief persona description].
```

## Process

1. Parse the tone name from `$ARGUMENTS` (first word, kebab-case)
2. Use remaining words as description/guidance (if any)
3. Generate the tone content following the format above
4. Write the file to `~/.claude/tones/<name>.md`
5. Confirm creation and show a preview of the tone
6. Ask: "Want to switch to this tone now?"
7. If yes, read and adopt the tone immediately

## Important

- Save as a **regular file** (not a symlink) — this is a local/custom tone
- Use kebab-case for the filename (e.g., `surfer-dude.md`, not `surfer dude.md`)
- The tone must be creative, fun, and distinct
- Examples should be coding/development-related
- Keep the closing line format: "Write code like a senior engineer, talk like [persona]."
