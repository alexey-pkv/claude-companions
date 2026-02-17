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

function Resolve-SymlinkTarget {
    param([string]$Path)
    $item = Get-Item $Path -Force
    if ($item.LinkType -eq "SymbolicLink") {
        $target = $item.Target
        if ($target -is [array]) { $target = $target[0] }
        return $target
    }
    return $null
}

function Uninstall-SingleTone {
    param([string]$Name)
    $Target = Join-Path $ClaudeTones "$Name.md"
    if (-not (Test-Path $Target)) {
        Write-Host "Tone '$Name' is not installed"
        return
    }
    $LinkTarget = Resolve-SymlinkTarget -Path $Target
    $RepoSource = Join-Path $RepoTones "$Name.md"
    if ($LinkTarget -and ($LinkTarget -eq $RepoSource)) {
        Remove-Item $Target -Force
        Write-Host "Uninstalled tone: $Name"
    } elseif ($LinkTarget) {
        Write-Warning "Tone '$Name' symlink points elsewhere ($LinkTarget). Skipping."
    } else {
        Write-Warning "Tone '$Name' is a local file, not a repo symlink. Skipping."
    }
}

function Uninstall-AllTones {
    if (-not (Test-Path $ClaudeTones)) { return }
    $Count = 0
    Get-ChildItem -Path $ClaudeTones -Filter "*.md" -File | ForEach-Object {
        $LinkTarget = Resolve-SymlinkTarget -Path $_.FullName
        if ($LinkTarget -and ($LinkTarget -like "$RepoTones*")) {
            Remove-Item $_.FullName -Force
            Write-Host "  Removed: $($_.BaseName)"
            $Count++
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
        try {
            $Settings = Get-Content $SettingsFile -Raw -Encoding UTF8 | ConvertFrom-Json
        } catch {
            Write-Warning "Could not parse settings.json"
            return
        }

        if ((Get-Member -InputObject $Settings -Name "hooks" -MemberType NoteProperty) -and
            (Get-Member -InputObject $Settings.hooks -Name "SessionStart" -MemberType NoteProperty)) {

            $Filtered = @()
            foreach ($Entry in $Settings.hooks.SessionStart) {
                $HasRotate = $false
                if (Get-Member -InputObject $Entry -Name "hooks" -MemberType NoteProperty) {
                    foreach ($H in $Entry.hooks) {
                        if ((Get-Member -InputObject $H -Name "command" -MemberType NoteProperty) -and
                            ($H.command -like "*rotate-tone*")) {
                            $HasRotate = $true
                            break
                        }
                    }
                }
                if (-not $HasRotate) {
                    $Filtered += $Entry
                }
            }

            if ($Filtered.Count -eq 0) {
                $Settings.hooks.PSObject.Properties.Remove("SessionStart")
            } else {
                $Settings.hooks.SessionStart = $Filtered
            }

            # Clean up empty hooks object
            if (($Settings.hooks.PSObject.Properties | Measure-Object).Count -eq 0) {
                $Settings.PSObject.Properties.Remove("hooks")
            }

            $Settings | ConvertTo-Json -Depth 20 | Set-Content $SettingsFile -Encoding UTF8 -NoNewline
        }
    }
    Write-Host "Removed session-start hook"
}

function Uninstall-Skill {
    param([string]$Name, [string]$SubDir)
    $SkillDir = Join-Path $ClaudeSkills $SubDir
    $SkillFile = Join-Path $SkillDir "SKILL.md"
    if (-not (Test-Path $SkillFile)) {
        Write-Host "Skill '$Name' is not installed"
        return
    }
    $LinkTarget = Resolve-SymlinkTarget -Path $SkillFile
    $RepoSource = Join-Path $RepoDir "skills\$SubDir\SKILL.md"
    if ($LinkTarget -and ($LinkTarget -eq $RepoSource)) {
        Remove-Item $SkillFile -Force
        if ((Get-ChildItem $SkillDir -Force | Measure-Object).Count -eq 0) {
            Remove-Item $SkillDir -Force
        }
        Write-Host "Uninstalled skill: $Name"
    } elseif ($LinkTarget) {
        Write-Warning "Skill '$Name' symlink points elsewhere. Skipping."
    } else {
        Write-Warning "Skill '$Name' is not a repo symlink. Skipping."
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
    Write-Host "Usage: .\uninstall.ps1 [-All] [-Tones] [-Hook] [-ToneSkill] [-CreateSkill] [-Tone <n>]"
    Write-Host ""
    Write-Host "  -All          Uninstall everything"
    Write-Host "  -Tones        Uninstall all repo tones (keeps local tones)"
    Write-Host "  -Tone <n>  Uninstall a specific tone"
    Write-Host "  -Hook         Remove session-start hook"
    Write-Host "  -ToneSkill    Remove /tone skill"
    Write-Host "  -CreateSkill  Remove /create-tone skill"
}
