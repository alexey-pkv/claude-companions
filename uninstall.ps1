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

function Uninstall-SingleTone {
    param([string]$Name)
    $Target = Join-Path $ClaudeTones "$Name.md"
    if (-not (Test-Path $Target)) {
        Write-Host "Tone '$Name' is not installed"
        return
    }
    $Item = Get-Item $Target
    $RepoSource = Join-Path $RepoTones "$Name.md"
    if ($Item.LinkType -eq "SymbolicLink" -and $Item.Target -eq $RepoSource) {
        Remove-Item $Target -Force
        Write-Host "Uninstalled tone: $Name"
    } else {
        Write-Warning "Tone '$Name' is a local file, not a repo symlink. Skipping."
    }
}

function Uninstall-AllTones {
    if (-not (Test-Path $ClaudeTones)) { return }
    $Count = 0
    Get-ChildItem -Path $ClaudeTones -Filter "*.md" -File | ForEach-Object {
        $Item = Get-Item $_.FullName
        if ($Item.LinkType -eq "SymbolicLink") {
            $LinkTarget = $Item.Target
            if ($LinkTarget -like "$RepoTones*") {
                Remove-Item $_.FullName -Force
                $Count++
            }
        }
    }
    Write-Host "Uninstalled $Count tones"
}

function Uninstall-Hook {
    # Remove rotate script symlink
    $ScriptPath = Join-Path $ClaudeScripts "rotate-tone.ps1"
    if (Test-Path $ScriptPath) {
        Remove-Item $ScriptPath -Force
        Write-Host "Removed rotate-tone script"
    }

    # Remove hook from settings.json
    if (Test-Path $SettingsFile) {
        $Settings = Get-Content $SettingsFile -Raw | ConvertFrom-Json -AsHashtable
        if ($Settings.ContainsKey("hooks") -and $Settings["hooks"].ContainsKey("SessionStart")) {
            $Settings["hooks"]["SessionStart"] = @(
                $Settings["hooks"]["SessionStart"] | Where-Object {
                    $dominated = $false
                    foreach ($H in $_.hooks) {
                        if ($H.command -like "*rotate-tone*") { $dominated = $true }
                    }
                    -not $dominated
                }
            )
            if ($Settings["hooks"]["SessionStart"].Count -eq 0) {
                $Settings["hooks"].Remove("SessionStart")
            }
            if ($Settings["hooks"].Count -eq 0) {
                $Settings.Remove("hooks")
            }
            $Settings | ConvertTo-Json -Depth 10 | Set-Content $SettingsFile -Encoding UTF8
        }
    }
    Write-Host "Removed session-start hook"
}

function Uninstall-Skill {
    param([string]$Name, [string]$SubDir)
    $SkillDir = Join-Path $ClaudeSkills $SubDir
    $SkillFile = Join-Path $SkillDir "SKILL.md"
    if (Test-Path $SkillFile) {
        $Item = Get-Item $SkillFile
        $RepoSource = Join-Path $RepoDir "skills\$SubDir\SKILL.md"
        if ($Item.LinkType -eq "SymbolicLink" -and $Item.Target -eq $RepoSource) {
            Remove-Item $SkillFile -Force
            if ((Get-ChildItem $SkillDir).Count -eq 0) {
                Remove-Item $SkillDir -Force
            }
            Write-Host "Uninstalled skill: $Name"
        } else {
            Write-Warning "Skill '$Name' is not a repo symlink. Skipping."
        }
    }
}

if ($All) {
    Uninstall-AllTones
    Uninstall-Hook
    Uninstall-Skill -Name "/tone" -SubDir "tone"
    Uninstall-Skill -Name "/create-tone" -SubDir "create-tone"
    Write-Host "`nAll components uninstalled!"
    exit 0
}

if ($Tone) { Uninstall-SingleTone -Name $Tone }
if ($Tones) { Uninstall-AllTones }
if ($Hook) { Uninstall-Hook }
if ($ToneSkill) { Uninstall-Skill -Name "/tone" -SubDir "tone" }
if ($CreateSkill) { Uninstall-Skill -Name "/create-tone" -SubDir "create-tone" }

if (-not ($All -or $Tone -or $Tones -or $Hook -or $ToneSkill -or $CreateSkill)) {
    Write-Host "Usage: .\uninstall.ps1 [-All] [-Tones] [-Hook] [-ToneSkill] [-CreateSkill] [-Tone <name>]"
    Write-Host ""
    Write-Host "  -All          Uninstall everything"
    Write-Host "  -Tones        Uninstall all repo tones (keeps local tones)"
    Write-Host "  -Tone <name>  Uninstall a specific tone"
    Write-Host "  -Hook         Remove session-start hook"
    Write-Host "  -ToneSkill    Remove /tone skill"
    Write-Host "  -CreateSkill  Remove /create-tone skill"
}
