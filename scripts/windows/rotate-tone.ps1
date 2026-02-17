$TonesDir = Join-Path $env:USERPROFILE ".claude\tones"

# Exit gracefully if tones directory doesn't exist
if (-not (Test-Path $TonesDir)) {
    exit 0
}

# Get all .md files
$ToneFiles = Get-ChildItem -Path $TonesDir -Filter "*.md" -File

# Exit gracefully if no tones exist
if ($ToneFiles.Count -eq 0) {
    exit 0
}

# Randomly select one
$Selected = $ToneFiles | Get-Random
$ToneName = $Selected.BaseName

# Output the tone content with explicit UTF8 encoding for special characters
Write-Output "🎭 Tone for this session: $ToneName"
Write-Output ""
Get-Content $Selected.FullName -Encoding UTF8
