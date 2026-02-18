[CmdletBinding()]
param(
    [switch]$All,
    [switch]$Tones,
    [switch]$Hook,
    [switch]$ToneSkill,
    [switch]$CreateSkill,
    [string]$Tone
)

$RepoDir = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
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
    Copy-Item $Source $Target -Force
    Write-Host "Installed tone: $Name"
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
    $ScriptSource = Join-Path $RepoDir "scripts\windows\rotate-tone.ps1"
    $ScriptTarget = Join-Path $ClaudeScripts "rotate-tone.ps1"
    Copy-Item $ScriptSource $ScriptTarget -Force

    # Build the hook command
    $RotateScript = Join-Path $env:USERPROFILE ".claude\scripts\rotate-tone.ps1"
    $HookCommand = "powershell -ExecutionPolicy Bypass -File `"$RotateScript`""

    # Read or initialize settings
    if (Test-Path $SettingsFile) {
        try {
            $SettingsJson = Get-Content $SettingsFile -Raw -Encoding UTF8
            $Settings = $SettingsJson | ConvertFrom-Json
        } catch {
            Write-Warning "Could not parse settings.json, creating fresh"
            $Settings = [PSCustomObject]@{}
        }
    } else {
        New-Item -ItemType Directory -Path $ClaudeDir -Force | Out-Null
        $Settings = [PSCustomObject]@{}
    }

    # Ensure hooks.SessionStart exists
    if (-not (Get-Member -InputObject $Settings -Name "hooks" -MemberType NoteProperty)) {
        $Settings | Add-Member -NotePropertyName "hooks" -NotePropertyValue ([PSCustomObject]@{})
    }
    if (-not (Get-Member -InputObject $Settings.hooks -Name "SessionStart" -MemberType NoteProperty)) {
        $Settings.hooks | Add-Member -NotePropertyName "SessionStart" -NotePropertyValue @()
    }

    # Check if hook already exists
    $Exists = $false
    foreach ($Entry in $Settings.hooks.SessionStart) {
        if (-not (Get-Member -InputObject $Entry -Name "hooks" -MemberType NoteProperty)) { continue }
        foreach ($H in $Entry.hooks) {
            if (-not (Get-Member -InputObject $H -Name "command" -MemberType NoteProperty)) { continue }
            if ($H.command -like "*rotate-tone*") {
                $Exists = $true
                break
            }
        }
        if ($Exists) { break }
    }

    if (-not $Exists) {
        $NewHook = [PSCustomObject]@{
            type = "command"
            command = $HookCommand
        }
        $NewEntry = [PSCustomObject]@{
            hooks = @($NewHook)
        }

        $CurrentEntries = @($Settings.hooks.SessionStart)
        $CurrentEntries += $NewEntry
        $Settings.hooks.SessionStart = $CurrentEntries
    }

    $Settings | ConvertTo-Json -Depth 20 | Set-Content $SettingsFile -Encoding UTF8 -NoNewline
    Write-Host "Installed session-start hook"
}

function Install-Skill {
    param([string]$Name, [string]$SubDir)
    $Source = Join-Path $RepoDir "skills\$SubDir\SKILL.md"
    if (-not (Test-Path $Source)) {
        Write-Error "Skill source not found: $Source"
        return
    }
    $TargetDir = Join-Path $ClaudeSkills $SubDir
    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
    $Target = Join-Path $TargetDir "SKILL.md"
    Copy-Item $Source $Target -Force
    Write-Host "Installed skill: $Name"
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
    Write-Host "Usage: .\install.ps1 [-All] [-Tones] [-Hook] [-ToneSkill] [-CreateSkill] [-Tone <n>]"
    Write-Host ""
    Write-Host "  -All          Install everything"
    Write-Host "  -Tones        Install all predefined tones"
    Write-Host "  -Tone <n>  Install a specific tone"
    Write-Host "  -Hook         Install session-start random tone hook"
    Write-Host "  -ToneSkill    Install /tone skill"
    Write-Host "  -CreateSkill  Install /create-tone skill"
}
