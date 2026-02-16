#!/bin/bash
set -e
source "$(dirname "$0")/common.sh"

git -C "$REPO_DIR" pull

# Calculate max tone name width
max_width=4
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

echo ""
printf "%-${col}s %-12s\n" "Tone" "Status"
printf "%-${col}s %-12s\n" "----" "------"

new=0; installed=0; local_count=0
seen=""

for f in "$REPO_TONES"/*.md; do
    [ -f "$f" ] || continue
    name=$(basename "$f" .md)
    seen="$seen $name"
    if [ -L "$CLAUDE_TONES/$name.md" ]; then
        printf "%-${col}s %-12s\n" "$name" "installed"
        installed=$((installed + 1))
    else
        printf "%-${col}s %-12s\n" "$name" "NEW"
        new=$((new + 1))
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
            printf "%-${col}s %-12s\n" "$name" "local"
            local_count=$((local_count + 1))
        fi
    done
fi

echo ""
printf "New: %d | Installed: %d | Local: %d\n" "$new" "$installed" "$local_count"

if [ "$new" -gt 0 ]; then
    echo ""
    echo "Run 'make install-tones' to install new tones."
fi
