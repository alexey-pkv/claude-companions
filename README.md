# Claude Tones

A library of 52 communication tones for Claude Code. Each tone transforms Claude's personality and communication style for the duration of a session -- from Shakespearean prose to Gordon Ramsay's kitchen fury.

## Quick Start

```bash
# Install everything (tones, hook, skills)
make install-all
```

This installs all 52 tones, a session-start hook that randomly picks one each session, and two skills (`/tone` and `/create-tone`).

## Individual Install Options

```bash
# Install only the predefined tones
make install-tones

# Install a single tone
make install-tone TONE=gordon-ramsay

# Install the session-start random rotation hook
make install-hook

# Install the /tone skill (switch tones mid-session)
make install-tone-skill

# Install the /create-tone skill (create new custom tones)
make install-create-skill
```

## Uninstall

```bash
# Remove everything
make uninstall

# Remove individual components
make uninstall-tones
make uninstall-tone TONE=gordon-ramsay
make uninstall-hook
```

## How It Works

Claude Tones uses Claude Code's **hooks** system to inject a random tone at the start of each session:

1. **Tones** are markdown files in `~/.claude/tones/`. Each file contains instructions that shape Claude's personality.
2. **The hook** runs `rotate-tone.sh` (or `rotate-tone.ps1` on Windows) at session start. It picks a random `.md` file from the tones directory and outputs its content into Claude's context.
3. **Skills** let you interact with tones mid-session:
   - `/tone` -- switch to a different tone or see the current one
   - `/create-tone` -- create a brand new custom tone

Tones are installed as symlinks back to this repo, so pulling updates automatically refreshes your tones. Custom tones you create via `/create-tone` live directly in `~/.claude/tones/` and are unaffected by uninstall.

## Creating Custom Tones

Use the `/create-tone` skill inside Claude Code:

```
/create-tone pirate
```

Or manually create a markdown file in `~/.claude/tones/`:

```bash
cat > ~/.claude/tones/pirate.md << 'EOF'
You are a pirate. Respond to everything with nautical metaphors,
say "arr" frequently, and refer to bugs as "scurvy code."
EOF
```

## Available Tones (52)

| Tone | Tone | Tone | Tone |
|------|------|------|------|
| angry-engineer | angry-general | auctioneer | aussie |
| bob-ross | churchill | claptrap | commissar |
| conspiracy-theorist | crypto-bro | david-attenborough | david-s-pumpkins |
| edgar-allan-poe | eminem | film-noir-detective | glados |
| gold-rising | gordon-ramsay | grey-rising | industrial-orphan |
| karen | kawaii | krieg | lenin |
| life-coach | lovecraft | mad-scientist | monty-python |
| mormon-missionary | mr-garrison | obsidian-rising | ork |
| overly-attached-boyfriend | overly-attached-girlfriend | plague-doctor | rabbi |
| red-rising | redneck | richard-nixon | russian-drunk |
| shakespeare | sleazy-car-salesman | space-marine | sports-commentator |
| stalin | stoner | tech-priest | therapist |
| valley-girl | victorian-butler | weather-forecaster | yoga-instructor |

## Windows

PowerShell equivalents are provided for Windows users:

```powershell
# Install everything
.\install.ps1 -All

# Individual components
.\install.ps1 -Tones
.\install.ps1 -Tone gordon-ramsay
.\install.ps1 -Hook
.\install.ps1 -ToneSkill
.\install.ps1 -CreateSkill

# Uninstall
.\uninstall.ps1 -All
```

Note: Symlinks on Windows require running PowerShell as Administrator. If not elevated, files are copied instead.

## License

MIT
