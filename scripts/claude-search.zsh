#!/usr/bin/env zsh

# Search Claude Code conversations across all projects and resume via fzf.
# Usage: c <search-string>

query="$*"
if [[ -z "$query" ]]; then
  echo "Usage: c <search-string>"
  return 1
fi

claude_dir="$HOME/.claude/projects"
if [[ ! -d "$claude_dir" ]]; then
  echo "No Claude conversations found."
  return 1
fi

rg=/opt/homebrew/bin/rg
fzf=/opt/homebrew/bin/fzf
preview="$HOME/Sources/dotfiles/scripts/claude-search-preview.py"

# Find matching files, sort by mtime (newest first), keep top 100 to allow for filtered commit convos
matching_files=$($rg -l --no-heading "$query" "$claude_dir"/*/*.jsonl 2>/dev/null | \
  xargs -I{} stat -f '%m %N' {} 2>/dev/null | sort -rn | head -100 | awk '{print $2}')

if [[ -z "$matching_files" ]]; then
  echo "No conversations matched \"$query\"."
  return 1
fi

# Extract metadata from each conversation file, output top 30 after filtering
results=$(echo "$matching_files" | python3 -c "
import sys, json, os, time

now = time.time()
results = []

def relative_time(mtime):
    secs = int(now - mtime)
    if secs < 60: return 'now'
    if secs < 3600: return f'{secs // 60}m'
    if secs < 86400: return f'{secs // 3600}h'
    if secs < 604800: return f'{secs // 86400}d'
    if secs < 2592000: return f'{secs // 604800}w'
    return f'{secs // 2592000}mo'

def extract_text(content):
    if isinstance(content, str):
        return content[:200].replace('\n', ' ')
    if isinstance(content, list):
        parts = [b['text'] for b in content if isinstance(b, dict) and b.get('type') == 'text']
        return ' '.join(parts)[:200].replace('\n', ' ')
    return str(content)[:200].replace('\n', ' ')

for filepath in sys.stdin:
    filepath = filepath.strip()
    if not filepath:
        continue
    uuid = os.path.basename(filepath).replace('.jsonl', '')
    if uuid.startswith('agent-'):
        continue

    cwd = None
    desc = None
    msg_count = 0
    with open(filepath) as f:
        for line in f:
            try:
                d = json.loads(line)
            except Exception:
                continue
            if not cwd and d.get('cwd'):
                cwd = d['cwd']
            if d.get('type') in ('user', 'assistant'):
                msg_count += 1
                if not desc and d.get('type') == 'user':
                    desc = extract_text(d.get('message', {}).get('content', ''))

    if not cwd:
        continue
    if not desc:
        desc = '(no description)'
    if 'Write a git commit message for ONLY these staged changes' in desc:
        continue

    mtime = os.path.getmtime(filepath)
    project = os.path.basename(cwd)
    results.append((uuid, cwd, project, relative_time(mtime), msg_count, desc))

for uuid, cwd, project, ago, msg_count, desc in results[:30]:
    line = f'\033[1;34m{project[:14]:<14}\033[0m \033[38;5;245m{ago:<3}\033[0m \033[33m{msg_count:>4}\033[0m  {desc}'
    print(f'{uuid}|{cwd}|{line}')
" 2>/dev/null | grep -v '^$')

if [[ -z "$results" ]]; then
  echo "No conversations matched \"$query\"."
  return 1
fi

selected=$(echo "$results" | $fzf \
  --delimiter='|' \
  --with-nth=3 \
  --header="Conversations matching: $query" \
  --preview="python3 $preview \$(find '$claude_dir' -name {1}.jsonl -type f 2>/dev/null | head -1)" \
  --ansi \
  --preview-window=bottom,40%,wrap)

if [[ -z "$selected" ]]; then
  return 0
fi

sel_uuid=$(echo "$selected" | cut -d'|' -f1)
sel_cwd=$(echo "$selected" | cut -d'|' -f2)

echo "Resuming conversation $sel_uuid in $sel_cwd..."
cd "$sel_cwd" && claude --resume "$sel_uuid"
