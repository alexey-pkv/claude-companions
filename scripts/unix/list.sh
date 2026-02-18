#!/bin/bash
set -e
source "$(dirname "$0")/common.sh"

# Calculate max tone name width
max_width=4  # minimum: length of "Tone"
for f in "$REPO_TONES"/*.md; do
    [ -f "$f" ] || continue
    name=$(basename "$f" .md)
    len=${#name}
    if [ "$len" -gt "$max_width" ]; then max_width=$len; fi
done
if [ -d "$CLAUDE_TONES" ]; then
    for f in "$CLAUDE_TONES"/*.md; do
        [ -f "$f" ] || continue
        name=$(basename "$f" .md)
        len=${#name}
        if [ "$len" -gt "$max_width" ]; then max_width=$len; fi
    done
fi
col=$((max_width + 2))

printf "%-${col}s %-12s %s\n" "Tone" "Status" "Source"
printf "%-${col}s %-12s %s\n" "----" "------" "------"

installed=0; available=0; local_count=0; modified=0
seen=""

for f in "$REPO_TONES"/*.md; do
    [ -f "$f" ] || continue
    name=$(basename "$f" .md)
    seen="$seen $name"
    if [ -f "$CLAUDE_TONES/$name.md" ]; then
        if cmp -s "$f" "$CLAUDE_TONES/$name.md"; then
            printf "%-${col}s %-12s %s\n" "$name" "installed" "$f"
            installed=$((installed + 1))
        else
            printf "%-${col}s %-12s %s\n" "$name" "modified" "$CLAUDE_TONES/$name.md"
            modified=$((modified + 1))
        fi
    else
        printf "%-${col}s %-12s %s\n" "$name" "available" "$f"
        available=$((available + 1))
    fi
done

if [ -d "$CLAUDE_TONES" ]; then
    for f in "$CLAUDE_TONES"/*.md; do
        [ -f "$f" ] || continue
        name=$(basename "$f" .md)
        is_seen=0
        for s in $seen; do
            if [ "$s" = "$name" ]; then is_seen=1; break; fi
        done
        if [ "$is_seen" = "0" ]; then
            printf "%-${col}s %-12s %s\n" "$name" "local" "$CLAUDE_TONES/$name.md"
            local_count=$((local_count + 1))
        fi
    done
fi

echo ""
printf "Installed: %d | Available: %d | Modified: %d | Local: %d\n" \
    "$installed" "$available" "$modified" "$local_count"
