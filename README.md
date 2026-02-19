# Claude Companions

Do you ever feel like Claude is just too... *polite*? Too measured? Too "I'd be happy to help you with that"?

Do you need someone to tell you the honest truth: **your code is sh\*t** — but in the voice of Gordon Ramsay screaming "YOUR TESTS ARE RAW!"? Or do you want to roleplay as your favorite Warhammer character while shipping critical hotfixes to production at 3 AM?

**Well, wait no more.** Claude Companions is a collection of communication tones for Claude Code. Each tone transforms how Claude talks to you for the duration of a session — from Victorian butler to unhinged mad scientist.

> **⚠️ Tones only affect how Claude communicates with you.** Code quality, commit messages, technical decisions, and all professional output remain completely unaffected. You still get principal-engineer-grade work — it's just delivered by a pirate. Or a drill sergeant. Or Edgar Allan Poe.


## Examples

**Gordon Ramsay** (`/tone gordon-ramsay`):

> BLOODY HELL! You're passing an EMPTY LIST to that function! `len(numbers)` is ZERO, you DONKEY! Division by zero! **IT'S RAW!**
>
> ```python
> def average(numbers):
>     if not numbers:
>         return 0
>     total = sum(numbers)
>     return total / len(numbers)
> ```
>
> THERE! Was that so hard?! Now GET OUT OF MY KITCHEN!

**Kawaii** (`/tone kawaii`):

> Uwaa~! Found it, senpai! (ﾉ◕ヮ◕)ﾉ\*:･ﾟ✧ The empty list makes it do division by zero — not kawaii at all, desu! Let me fix it with super cute error handling magic~ ✨
>
> ```python
> def average(numbers):
>     if not numbers:
>         return 0
>     total = sum(numbers)
>     return total / len(numbers)
> ```
>
> Yatta~! Now it's safe and adorable! (◕‿◕)♡


## Quick Start

```bash
git clone https://github.com/alexey-pkv/claude-companions.git claude-companions
cd claude-companions
claude "Install everything!"
```

That's it. Claude reads the `CLAUDE.md` in this repo and knows how to install everything.


## Using with Claude

The recommended way to manage tones is to just talk to Claude from this directory. The `CLAUDE.md` file contains all the instructions Claude needs, so you can simply say:

```
claude "Install all tones"
claude "Install just gordon-ramsay and shakespeare"
claude "Remove the hook, I want to pick tones manually"
claude "Create a new tone called pirate-captain"
```

No need to memorize commands — just tell Claude what you want.


## Make Commands

If you prefer running commands directly, (like a peasant):

### Install

| Command                                | Description                                |
|----------------------------------------|--------------------------------------------|
| `make install-all`                     | Install everything (tones, hook, skills)   |
| `make install-tones`                   | Install all predefined tones               |
| `make install-tone TONE=gordon-ramsay` | Install a single tone                      |
| `make install-hook`                    | Install session-start random tone rotation |
| `make install-tone-skill`              | Install the `/tone` skill                  |
| `make install-create-skill`            | Install the `/create-tone` skill           |

**Windows (PowerShell):**

```powershell
.\scripts\windows\install.ps1 [-All | -Tones | -Tone <name> | -Hook | -ToneSkill | -CreateSkill]
```

| Flag                  | Description                  |
|-----------------------|------------------------------|
| `-All`                | Install everything           |
| `-Tones`              | Install all tones            |
| `-Tone <name>`        | Install a single tone        |
| `-Hook`               | Install session-start hook   |
| `-ToneSkill`          | Install `/tone` skill        |
| `-CreateSkill`        | Install `/create-tone` skill |

### Uninstall

| Command                                  | Description                               |
|------------------------------------------|-------------------------------------------|
| `make uninstall`                         | Remove everything                         |
| `make uninstall-tones`                   | Remove all repo tones (keeps local tones) |
| `make uninstall-tone TONE=gordon-ramsay` | Remove a single tone                      |
| `make uninstall-hook`                    | Remove session-start hook                 |

**Windows (PowerShell):**

```powershell
.\scripts\windows\uninstall.ps1 [-All | -Tones | -Tone <name> | -Hook]
```

| Flag           | Description               |
|----------------|---------------------------|
| `-All`         | Remove everything         |
| `-Tones`       | Remove all repo tones     |
| `-Tone <name>` | Remove a single tone      |
| `-Hook`        | Remove session-start hook |

### Other

| Command       | Description                      |
|---------------|----------------------------------|
| `make list`   | Show all tones and their status  |
| `make status` | Show current installation status |

To update, pull the latest changes and re-install:

```bash
git pull && make install-all
```


## How It Works

Claude Companions uses Claude Code's **hooks** system to inject a random tone at the start of each session:

1. **Tones** are markdown files that shape how Claude talks. When installed, they are copied to `~/.claude/tones/`.
2. **The hook** runs a rotation script at session start. It picks a random tone and injects it into Claude's context.
3. **Skills** let you interact with tones mid-session:
   - `/tone` — switch to a different tone, pick a random one, or list available tones
   - `/create-tone` — create a brand new custom tone

Custom tones you create via `/create-tone` live directly in `~/.claude/tones/` alongside installed tones. To get updated tones after pulling the repo, re-run the install.


## Skills

Two optional skills give you control over tones mid-session.

### `/tone` — Switch, List, or Randomize Tones

| Usage                 | Description                        |
|-----------------------|------------------------------------|
| `/tone`               | List all available tones           |
| `/tone random`        | Pick a random tone for the session |
| `/tone gordon-ramsay` | Switch to a specific tone          |

If the tone name isn't found, Claude will suggest the closest match or offer to create it.

```
> /tone random
🎭 Tone loaded: shakespeare

Hark! What task doth thou bring before me this fine session?

> /tone kawaii
🎭 Tone loaded: kawaii

Uwaa~! Ready to help, senpai! (◕‿◕)♡
```

### `/create-tone` — Create a Custom Tone

Generate a new tone from a name and optional description.

| Usage                                                                    | Description                                |
|--------------------------------------------------------------------------|--------------------------------------------|
| `/create-tone pirate-captain`                                            | Generate a tone from the name alone        |
| `/create-tone surfer-dude laid back California surfer who says "gnarly"` | Use a description for guidance             |
| `/create-tone give me 10 South Park characters to choose from`           | Ask for a list of suggestions to pick from |

The generated tone is saved to `~/.claude/tones/<name>.md` and you'll be asked if you want to switch to it immediately.

```
> /create-tone medieval-peasant

🎭 Created tone: medieval-peasant
Preview: "Oi, milord! This 'ere function be rotten as a turnip..."
Want to switch to this tone now?
```

You can also ask Claude directly without the slash command:

```
claude "Create a new tone called surfer-dude that talks like a California surfer"
```


## License

MIT
