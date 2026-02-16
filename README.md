# Claude Companions

Do you ever feel like Claude is just too... *polite*? Too measured? Too "I'd be happy to help you with that"?

Do you need someone to tell you the honest truth: **your code is sh\*t** — but in the voice of Gordon Ramsay screaming "YOUR TESTS ARE RAW!"? Or do you want to roleplay as your favorite Warhammer character while shipping critical hotfixes to production at 3 AM?

**Well, wait no more.** Claude Companions is a collection of communication tones for Claude Code. Each tone transforms how Claude talks to you for the duration of a session — from Victorian butler to unhinged mad scientist.

> **⚠️ Tones only affect how Claude communicates with you.** Code quality, commit messages, technical decisions, and all professional output remain completely unaffected. You still get principal-engineer-grade work — it's just delivered by a pirate. Or a drill sergeant. Or Edgar Allan Poe.

## Quick Start

```bash
git clone https://github.com/alexey-pkv/claude-companions.git claude-tones
cd claude-tones
claude "Install everything"
```

That's it. Claude reads the `CLAUDE.md` in this repo and knows how to install everything.

## Using with Claude

The recommended way to manage tones is to just talk to Claude from this directory. The `CLAUDE.md` file contains all the instructions Claude needs, so you can simply say:

```
claude "Install all tones"
claude "Install just gordon-ramsay and shakespeare"
claude "Remove the hook, I want to pick tones manually"
claude "Update tones"
claude "Create a new tone called pirate-captain"
```

No need to memorize commands — just tell Claude what you want.

## Make Commands

If you prefer running commands directly, like a peasant:

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

| Command                                             | Description                  |
|-----------------------------------------------------|------------------------------|
| `.\scripts\windows\install.ps1 -All`                | Install everything           |
| `.\scripts\windows\install.ps1 -Tones`              | Install all tones            |
| `.\scripts\windows\install.ps1 -Tone gordon-ramsay` | Install a single tone        |
| `.\scripts\windows\install.ps1 -Hook`               | Install session-start hook   |
| `.\scripts\windows\install.ps1 -ToneSkill`          | Install `/tone` skill        |
| `.\scripts\windows\install.ps1 -CreateSkill`        | Install `/create-tone` skill |

> Note: Symlinks on Windows require running PowerShell as Administrator. If not elevated, files are copied instead.

### Uninstall

| Command                                  | Description                               |
|------------------------------------------|-------------------------------------------|
| `make uninstall`                         | Remove everything                         |
| `make uninstall-tones`                   | Remove all repo tones (keeps local tones) |
| `make uninstall-tone TONE=gordon-ramsay` | Remove a single tone                      |
| `make uninstall-hook`                    | Remove session-start hook                 |

**Windows (PowerShell):**

| Command                                               | Description               |
|-------------------------------------------------------|---------------------------|
| `.\scripts\windows\uninstall.ps1 -All`                | Remove everything         |
| `.\scripts\windows\uninstall.ps1 -Tones`              | Remove all repo tones     |
| `.\scripts\windows\uninstall.ps1 -Tone gordon-ramsay` | Remove a single tone      |
| `.\scripts\windows\uninstall.ps1 -Hook`               | Remove session-start hook |

### Other

| Command       | Description                      |
|---------------|----------------------------------|
| `make list`   | Show all tones and their status  |
| `make status` | Show current installation status |
| `make update` | Pull latest and show what's new  |

## Example: Gordon Ramsay Tone

> **User:** Write me a Python CLI script that takes a directory path and prints a tree view of files and folders

> THERE! LOOK AT THAT! **BEAUTIFUL!** A clean, professional Python script that actually WORKS!
>
> ```python
> def print_tree(directory: Path, prefix: str = "", is_last: bool = True) -> None:
>     connector = "└── " if is_last else "├── "
>     print(f"{prefix}{connector}{directory.name}/")
>     prefix += "    " if is_last else "│   "
>
>     try:
>         entries = sorted(directory.iterdir(), key=lambda x: (not x.is_dir(), x.name))
>     except PermissionError:
>         print(f"{prefix}[Permission Denied]")
>         return
>
>     for index, entry in enumerate(entries):
>         is_last_entry = index == len(entries) - 1
>         connector = "└── " if is_last_entry else "├── "
>         if entry.is_dir():
>             print_tree(entry, prefix, is_last_entry)
>         else:
>             print(f"{prefix}{connector}{entry.name}")
> ```
>
> See what I did here, you DONKEY? Proper error handling for missing directories and permissions! Sorted output with directories FIRST! Clean recursion with proper Unicode box-drawing characters!
>
> The code uses `pathlib` because we're not SAVAGES using string concatenation like it's 1995! NOW GET OUT OF MY KITCHEN!

## How It Works

Claude Companions uses Claude Code's **hooks** system to inject a random tone at the start of each session:

1. **Tones** are markdown files that shape how Claude talks. When installed, they are symlinked to `~/.claude/tones/`.
2. **The hook** runs a rotation script at session start. It picks a random tone and injects it into Claude's context.
3. **Skills** let you interact with tones mid-session:
   - `/tone` — switch to a different tone, pick a random one, or list available tones
   - `/create-tone` — create a brand new custom tone

Tones are installed as symlinks back to this repo, so pulling updates automatically refreshes your tones. Custom tones you create via `/create-tone` live directly in `~/.claude/tones/` and are unaffected by uninstall.

## Creating Custom Tones

Use the `/create-tone` skill inside Claude Code:

```
/create-tone pirate-captain
```

Or ask Claude directly:

```
claude "Create a new tone called surfer-dude that talks like a California surfer"
```

## License

MIT
