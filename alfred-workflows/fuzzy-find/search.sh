#!/bin/bash

query="$1"

if [ -n "$query" ]; then
    echo "$query" > /tmp/alfred_fd_last_query
fi

check_deps() {
    if ! command -v fd &> /dev/null; then
        echo '{"items": [{"title": "fd not found", "subtitle": "Please install fd with: brew install fd", "valid": false}]}'
        exit 1
    fi
    if ! command -v fzf &> /dev/null; then
        echo '{"items": [{"title": "fzf not found", "subtitle": "Please install fzf with: brew install fzf", "valid": false}]}'
        exit 1
    fi
}

check_deps

if [ -z "$query" ]; then
    echo '{"items": []}'
    exit 0
fi

CACHE_FILE="/tmp/alfred_fd_cache"
CACHE_AGE=86400

if [ -f "$CACHE_FILE" ] && [ $(($(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0))) -lt $CACHE_AGE ]; then
    results=$(cat "$CACHE_FILE" | fzf --filter "$query" | head -10)
else
    (echo "$PWD"; fd . ~ --max-depth 7 \
        --exclude Library \
        --exclude Pictures \
        --exclude Music \
        --exclude node_modules \
        2>/dev/null) > "$CACHE_FILE"
    results=$(cat "$CACHE_FILE" | fzf --filter "$query" | head -10)
fi

echo '{"items": ['

first=true
while IFS= read -r path; do
    [ -z "$path" ] && continue
    
    if [ "$first" = true ]; then
        first=false
    else
        echo ","
    fi
    
    basename=$(basename "$path" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | sed ':a;N;$!ba;s/\n/\\n/g' | tr '\r' ' ')
    [ -z "$basename" ] && basename="$path"
    
    display_path="${path/#$HOME/~}" 
    display_path=$(echo "$display_path" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | sed ':a;N;$!ba;s/\n/\\n/g' | tr '\r' ' ')
    path_escaped=$(echo "$path" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | sed ':a;N;$!ba;s/\n/\\n/g' | tr '\r' ' ')
    
    if [ -d "$path" ]; then
        icon_type="fileicon"
    elif [[ "$path" =~ \.(jpg|jpeg|png|gif|webp|tiff|bmp|svg|ico)$ ]]; then
        icon_type="filepath"
    else
        icon_type="fileicon"
    fi
    
    cat <<EOF
    {
        "title": "$basename",
        "subtitle": "$display_path",
        "arg": "$path_escaped",
        "type": "file",
        "icon": {
            "type": "$icon_type",
            "path": "$path_escaped"
        },
        "valid": true
    }
EOF
done <<< "$results"

echo ']}'
