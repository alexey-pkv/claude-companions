[CmdletBinding()]
param(
    [switch]$All,
    [switch]$Tones,
    [switch]$Hook,
    [switch]$ToneSkill,
    [switch]$CreateSkill,
    [string]$Tone
)

$RepoDir = $PSScriptRoot
$RepoTones = Join-Path $RepoDir "tones"
$ClaudeDir = Join-Path $env:USERPROFILE ".claude"
$ClaudeTones = Join-Path $ClaudeDir "tones"
$ClaudeSkills = Join-Path $ClaudeDir "skills"
$ClaudeScripts = Join-Path $ClaudeDir "scripts"
$SettingsFile = Join-Path $ClaudeDir "settings.json"

function Install-SingleTone {
    param([string]$Name)
    $Source = Join-Path $RepoTones "$Name.md"
    if (-not (Test-Path $Source)) {
        Write-Error "Tone '$Name' not found in repo"
        return
    }
    New-Item -ItemType Directory -Path $ClaudeTones -Force | Out-Null
    $Target = Join-Path $ClaudeTones "$Name.md"
    # Windows: use symbolic link (requires appropriate permissions) or copy
    if (Test-Path $Target) { Remove-Item $Target -Force }
    try {
        New-Item -ItemType SymbolicLink -Path $Target -Target $Source -Force | Out-Null
        Write-Host "Installed tone: $Name (symlink)"
    } catch {
        Copy-Item $Source $Target -Force
        Write-Host "Installed tone: $Name (copy — run as admin for symlinks)"
    }
}

function Install-AllTones {
    New-Item -ItemType Directory -Path $ClaudeTones -Force | Out-Null
    $ToneFiles = Get-ChildItem -Path $RepoTones -Filter "*.md" -File
    foreach ($File in $ToneFiles) {
        Install-SingleTone -Name $File.BaseName
    }
    Write-Host "Installed $($ToneFiles.Count) tones"
}

function Install-Hook {
    New-Item -ItemType Directory -Path $ClaudeScripts -Force | Out-Null
    $ScriptSource = Join-Path $RepoDir "scripts\rotate-tone.ps1"
    $ScriptTarget = Join-Path $ClaudeScripts "rotate-tone.ps1"
    if (Test-Path $ScriptTarget) { Remove-Item $ScriptTarget -Force }
    try {
        New-Item -ItemType SymbolicLink -Path $ScriptTarget -Target $ScriptSource -Force | Out-Null
    } catch {
        Copy-Item $ScriptSource $ScriptTarget -Force
    }

    # Update settings.json
    $HookCommand = "powershell -ExecutionPolicy Bypass -File `"$env:USERPROFILE\.claude\scripts\rotate-tone.ps1`""
    $HookEntry = @{
        hooks = @(
            @{
                type = "command"
                command = $HookCommand
            }
        )
    }

    if (Test-Path $SettingsFile) {
        $Settings = Get-Content $SettingsFile -Raw | ConvertFrom-Json -AsHashtable
    } else {
        $Settings = @{}
    }

    if (-not $Settings.ContainsKey("hooks")) {
        $Settings["hooks"] = @{}
    }
    if (-not $Settings["hooks"].ContainsKey("SessionStart")) {
        $Settings["hooks"]["SessionStart"] = @()
    }

    # Check if hook already exists
    $Exists = $false
    foreach ($Entry in $Settings["hooks"]["SessionStart"]) {
        foreach ($H in $Entry.hooks) {
            if ($H.command -like "*rotate-tone*") {
                $Exists = $true
                break
            }
        }
    }

    if (-not $Exists) {
        $Settings["hooks"]["SessionStart"] += $HookEntry
    }

    $Settings | ConvertTo-Json -Depth 10 | Set-Content $SettingsFile -Encoding UTF8
    Write-Host "Installed session-start hook"
}

function Install-Skill {
    param([string]$Name, [string]$SubDir)
    $Source = Join-Path $RepoDir "skills\$SubDir\SKILL.md"
    $TargetDir = Join-Path $ClaudeSkills $SubDir
    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
    $Target = Join-Path $TargetDir "SKILL.md"
    if (Test-Path $Target) { Remove-Item $Target -Force }
    try {
        New-Item -ItemType SymbolicLink -Path $Target -Target $Source -Force | Out-Null
        Write-Host "Installed skill: $Name (symlink)"
    } catch {
        Copy-Item $Source $Target -Force
        Write-Host "Installed skill: $Name (copy — run as admin for symlinks)"
    }
}

# Execute based on switches
if ($All) {
    Install-AllTones
    Install-Hook
    Install-Skill -Name "/tone" -SubDir "tone"
    Install-Skill -Name "/create-tone" -SubDir "create-tone"
    Write-Host "`nAll components installed!"
    exit 0
}

if ($Tone) {
    Install-SingleTone -Name $Tone
}

if ($Tones) {
    Install-AllTones
}

if ($Hook) {
    Install-Hook
}

if ($ToneSkill) {
    Install-Skill -Name "/tone" -SubDir "tone"
}

if ($CreateSkill) {
    Install-Skill -Name "/create-tone" -SubDir "create-tone"
}

if (-not ($All -or $Tone -or $Tones -or $Hook -or $ToneSkill -or $CreateSkill)) {
    Write-Host "Usage: .\install.ps1 [-All] [-Tones] [-Hook] [-ToneSkill] [-CreateSkill] [-Tone <name>]"
    Write-Host ""
    Write-Host "  -All          Install everything"
    Write-Host "  -Tones        Install all predefined tones"
    Write-Host "  -Tone <name>  Install a specific tone"
    Write-Host "  -Hook         Install session-start random tone hook"
    Write-Host "  -ToneSkill    Install /tone skill"
    Write-Host "  -CreateSkill  Install /create-tone skill"
}
