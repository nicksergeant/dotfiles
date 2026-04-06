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

# Get hit counts per file (rg -c), sort by mtime, take top 100
hit_counts=$($rg -ci --no-heading "$query" "$claude_dir"/*/*.jsonl 2>/dev/null)

if [[ -z "$hit_counts" ]]; then
  echo "No conversations matched \"$query\"."
  return 1
fi

# Build file list sorted by mtime, with hit counts
# hit_counts format: /path/to/file.jsonl:count
sorted_files=$(echo "$hit_counts" | while IFS=: read -r file count; do
  mtime=$(stat -f '%m' "$file" 2>/dev/null)
  echo "$mtime|$count|$file"
done | sort -t'|' -k1 -rn | head -100)

# Get message counts in bulk with rg (count lines matching "type":"user" or "type":"assistant")
# Build a temp file list for rg
file_list=$(echo "$sorted_files" | cut -d'|' -f3)
msg_counts=$($rg -c --no-heading '"type":"user"\|"type":"assistant"' $=file_list 2>/dev/null; \
  $rg -c --no-heading '"type":"user"' $=file_list 2>/dev/null; \
  $rg -c --no-heading '"type":"assistant"' $=file_list 2>/dev/null)

# Pass sorted files (with mtime, hits) to python which only extracts cwd + desc from first few lines
results=$(echo "$sorted_files" | python3 -c "
import sys, json, os, time, subprocess

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

# Get message counts via rg -c in one shot
rg = '/opt/homebrew/bin/rg'
all_files = []
for line in sys.stdin:
    parts = line.strip().split('|', 2)
    if len(parts) != 3:
        continue
    all_files.append((int(parts[0]), int(parts[1]), parts[2]))

# Batch rg for message counts and custom titles
file_paths = [f for _, _, f in all_files]
msg_count_map = {}
title_map = {}
if file_paths:
    proc = subprocess.run(
        [rg, '-c', '--no-heading', '\"type\":\"user\"|\"type\":\"assistant\"', *file_paths],
        capture_output=True, text=True
    )
    for line in proc.stdout.splitlines():
        idx = line.rfind(':')
        if idx > 0:
            msg_count_map[line[:idx]] = int(line[idx+1:])

    proc = subprocess.run(
        [rg, '--no-heading', '-m1', '\"custom-title\"', *file_paths],
        capture_output=True, text=True
    )
    for line in proc.stdout.splitlines():
        idx = line.find('.jsonl:')
        if idx > 0:
            fp = line[:idx + 6]
            try:
                title_map[fp] = json.loads(line[idx + 7:]).get('customTitle')
            except Exception:
                pass

for mtime, hits, filepath in all_files:
    uuid = os.path.basename(filepath).replace('.jsonl', '')
    if uuid.startswith('agent-'):
        continue

    # Only read first 50 lines to find cwd, branch, and desc
    cwd = None
    branch = None
    desc = None
    with open(filepath) as f:
        for i, line in enumerate(f):
            if i > 50:
                break
            if (not cwd or not branch) and '\"cwd\"' in line:
                try:
                    d = json.loads(line)
                    if not cwd: cwd = d.get('cwd')
                    if not branch: branch = d.get('gitBranch')
                except Exception:
                    pass
            if not desc and '\"type\":\"user\"' in line:
                try:
                    d = json.loads(line)
                    if d.get('type') == 'user':
                        desc = extract_text(d.get('message', {}).get('content', ''))
                        if not branch: branch = d.get('gitBranch')
                except Exception:
                    pass
            if cwd and desc and branch:
                break

    # Grab custom title via rg (fast, avoids reading whole file in python)
    title = title_map.get(filepath)

    if not cwd:
        continue
    if not desc:
        desc = '(no description)'
    if 'Write a git commit message for ONLY these staged changes' in desc:
        continue

    msg_count = msg_count_map.get(filepath, 0)
    project = os.path.basename(cwd)
    display = title if title else desc
    results.append((uuid, filepath, cwd, project, branch or '', relative_time(mtime), msg_count, hits, display))

for uuid, filepath, cwd, project, branch, ago, msg_count, hits, display in results[:30]:
    br = (branch or '')[:12]
    line = f'\033[1;34m{project[:14]:<14}\033[0m \033[38;5;245m{ago:<3}\033[0m \033[38;5;245m{br:<12}\033[0m \033[33m{msg_count:>4}\033[0m \033[32m{hits:>4}\033[0m  {display}'
    print(f'{uuid}|{filepath}|{cwd}|{line}')
" 2>/dev/null | grep -v '^$')

if [[ -z "$results" ]]; then
  echo "No conversations matched \"$query\"."
  return 1
fi

selected=$(echo "$results" | $fzf \
  --delimiter='|' \
  --with-nth=4 \
  --header="Conversations matching: $query" \
  --preview="python3 $preview {2}" \
  --ansi \
  --preview-window=bottom,40%,wrap)

if [[ -z "$selected" ]]; then
  return 0
fi

sel_uuid=$(echo "$selected" | cut -d'|' -f1)
sel_cwd=$(echo "$selected" | cut -d'|' -f3)

echo "Resuming conversation $sel_uuid in $sel_cwd..."
cd "$sel_cwd" && claude --resume "$sel_uuid"
