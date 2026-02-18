[CmdletBinding()]
param(
    [switch]$All,
    [switch]$Tones,
    [switch]$Hook,
    [switch]$ToneSkill,
    [switch]$CreateSkill,
    [string]$Tone
)

$ClaudeDir = Join-Path $env:USERPROFILE ".claude"
$ClaudeTones = Join-Path $ClaudeDir "tones"
$ClaudeSkills = Join-Path $ClaudeDir "skills"
$ClaudeScripts = Join-Path $ClaudeDir "scripts"
$SettingsFile = Join-Path $ClaudeDir "settings.json"

function Uninstall-SingleTone {
    param([string]$Name)
    $Target = Join-Path $ClaudeTones "$Name.md"
    if (Test-Path $Target) {
        Remove-Item $Target -Force
        Write-Host "Uninstalled tone: $Name"
    } else {
        Write-Host "Tone '$Name' is not installed"
    }
}

function Uninstall-AllTones {
    if (Test-Path $ClaudeTones) {
        Remove-Item $ClaudeTones -Recurse -Force
        Write-Host "Removed all tones"
    } else {
        Write-Host "No tones installed"
    }
}

function Uninstall-Hook {
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

            if (($Settings.hooks.PSObject.Properties | Measure-Object).Count -eq 0) {
                $Settings.PSObject.Properties.Remove("hooks")
            }

            $Settings | ConvertTo-Json -Depth 20 | Set-Content $SettingsFile -Encoding UTF8 -NoNewline
        }
    }
    Write-Host "Removed SessionStart hook from settings"

    # Remove rotate script
    $ScriptPath = Join-Path $ClaudeScripts "rotate-tone.ps1"
    if (Test-Path $ScriptPath) {
        Remove-Item $ScriptPath -Force
        Write-Host "Removed rotate-tone script"
    }
}

function Uninstall-Skill {
    param([string]$Name, [string]$SubDir)
    $SkillDir = Join-Path $ClaudeSkills $SubDir
    if (Test-Path $SkillDir) {
        Remove-Item $SkillDir -Recurse -Force
        Write-Host "Uninstalled skill: $Name"
    } else {
        Write-Host "Skill '$Name' is not installed"
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
    Write-Host "  -Tones        Uninstall all tones"
    Write-Host "  -Tone <n>  Uninstall a specific tone"
    Write-Host "  -Hook         Remove session-start hook"
    Write-Host "  -ToneSkill    Remove /tone skill"
    Write-Host "  -CreateSkill  Remove /create-tone skill"
}
