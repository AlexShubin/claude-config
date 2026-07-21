#!/bin/bash
input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name')
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
dir=$(basename "$cwd")
pct=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
used=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
resets=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')

branch=$(cd "$cwd" 2>/dev/null && git --no-optional-locks branch --show-current 2>/dev/null)

out=$(printf '\033[36m%s\033[0m \033[33m%s\033[0m' "$model" "$dir")
[ -n "$branch" ] && out+=$(printf ' \033[32m%s\033[0m' "$branch")
[ -n "$pct" ] && out+=$(printf ' \033[35m%.0f%% left\033[0m' "$pct")
if [ -n "$used" ]; then
    limit=$(printf '%.0f%% used' "$used")
    if [ -n "$resets" ]; then
        secs=$(( resets - $(date +%s) ))
        if [ "$secs" -gt 0 ]; then
            limit+=$(printf ', resets %dh%02dm' $(( secs / 3600 )) $(( secs % 3600 / 60 )))
        fi
    fi
    out+=$(printf ' \033[31m%s\033[0m' "$limit")
fi

echo "$out"
