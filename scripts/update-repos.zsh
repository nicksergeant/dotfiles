#!/usr/bin/env zsh

################################################################################
# update-repos.zsh
#
# Updates git repositories by fetching and rebasing from origin.
#
# USAGE:
#   ./update-repos.zsh
#
# WHAT IT DOES:
#   - If run inside a git repo: fetches and rebases the current branch from origin
#   - If run in a parent directory: scans subdirectories for git repositories
#   - For repos on main branch with no uncommitted or unpushed changes:
#     * Fetches from origin/main
#     * Pulls if behind origin
#     * Reports update status
#   - Processes repos concurrently in batches of 20 for performance
#
# REPOS ARE SKIPPED IF:
#   - Not on the main branch
#   - Have uncommitted changes (modified, staged, or untracked files)
#   - Have unpushed commits (local commits ahead of origin/main)
#   - origin/main doesn't exist
#
# OUTPUT:
#   - Real-time status with color-coded symbols:
#     ✓ (green)  - Successfully pulled new commits
#     • (blue)   - Already up-to-date with origin/main
#     ⊘ (yellow) - Skipped (see reasons above)
#     ✗ (red)    - Error occurred during processing
#   - Summary line showing counts for each category
#
# HOW IT WORKS:
#   1. Identifies all git repos in the current directory (checks for .git directories)
#   2. Processes repos in batches of 20 concurrently to avoid overwhelming system
#   3. Each repo writes its status to a temp file
#   4. After processing completes, collects results and displays formatted output
#   5. Cleans up temp files on exit (via trap)
################################################################################

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

# Status symbols
SYMBOL_SUCCESS="✓"
SYMBOL_UPTODATE="•"
SYMBOL_SKIPPED="⊘"
SYMBOL_ERROR="✗"

# Temp directory for results
TEMP_DIR=$(mktemp -d)
trap "rm -rf '$TEMP_DIR'" EXIT

# Process a single repository
process_repo() {
    local repo_dir="$1"
    local repo_name=$(basename "$repo_dir")

    # Skip if repo_name is empty
    [[ -z "$repo_name" ]] && return 0

    local result_file="${TEMP_DIR}/${repo_name}.result"

    cd "$repo_dir" 2>/dev/null || {
        printf "ERROR\t%s\t%s\n" "$repo_name" "cannot access directory" > "$result_file"
        return 1
    }

    local current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [[ $? -ne 0 ]]; then
        printf "ERROR\t%s\t%s\n" "$repo_name" "cannot determine branch" > "$result_file"
        return 1
    fi

    if [[ "$current_branch" != "main" ]]; then
        printf "SKIPPED\t%s\t%s\n" "$repo_name" "on ${current_branch}" > "$result_file"
        return 0
    fi

    if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
        printf "SKIPPED\t%s\t%s\n" "$repo_name" "uncommitted changes" > "$result_file"
        return 0
    fi

    git fetch origin main >/dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        printf "ERROR\t%s\t%s\n" "$repo_name" "fetch failed" > "$result_file"
        return 1
    fi

    git rev-parse origin/main >/dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        printf "SKIPPED\t%s\t%s\n" "$repo_name" "no origin/main" > "$result_file"
        return 0
    fi

    local unpushed=$(git rev-list --count origin/main..HEAD 2>/dev/null || echo "0")
    if [[ $unpushed -gt 0 ]]; then
        printf "SKIPPED\t%s\t%s\n" "$repo_name" "${unpushed} unpushed commit(s)" > "$result_file"
        return 0
    fi

    local behind=$(git rev-list --count HEAD..origin/main 2>/dev/null)
    if [[ $? -ne 0 ]]; then
        printf "ERROR\t%s\t%s\n" "$repo_name" "cannot compare with origin" > "$result_file"
        return 1
    fi

    if [[ $behind -eq 0 ]]; then
        printf "UPTODATE\t%s\t%s\n" "$repo_name" "" > "$result_file"
        return 0
    fi

    git pull origin main >/dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        printf "ERROR\t%s\t%s\n" "$repo_name" "pull failed" > "$result_file"
        return 1
    fi

    printf "UPDATED\t%s\t%s\n" "$repo_name" "${behind} commit(s)" > "$result_file"
}

main() {
    local src_dir="$(pwd)"

    # If we're in a git repo, just fetch and rebase the current branch
    if [[ -d .git ]]; then
        local branch=$(git branch --show-current)
        git fetch origin "$branch" && git rebase "origin/$branch"
        return
    fi

    local repos=()
    for dir in "$src_dir"/*/; do
        if [[ -d "${dir}.git" ]]; then
            repos+=("$dir")
        fi
    done

    local repo_count=${#repos[@]}

    if [[ $repo_count -eq 0 ]]; then
        echo "No git repositories found in ${src_dir}"
        exit 0
    fi

    echo "Checking ${repo_count} directories in ${src_dir}..."
    echo ""

    # Process repos in batches to avoid overwhelming the system
    local batch_size=20
    local i=0

    while [[ $i -lt $repo_count ]]; do
        local batch_end=$((i + batch_size))
        [[ $batch_end -gt $repo_count ]] && batch_end=$repo_count

        # Launch batch
        local j=$i
        while [[ $j -lt $batch_end ]]; do
            process_repo "${repos[$j]}" &
            j=$((j + 1))
        done

        # Wait for batch to complete
        wait

        i=$batch_end
    done

    # Collect and display results
    local updated=0
    local uptodate=0
    local skipped=0
    local errors=0

    for result_file in "$TEMP_DIR"/*.result; do
        [[ -f "$result_file" ]] || continue

        local line=$(cat "$result_file" 2>/dev/null)
        [[ -z "$line" ]] && continue

        local repo_status=$(echo "$line" | cut -f1)
        local name=$(echo "$line" | cut -f2)
        local message=$(echo "$line" | cut -f3)

        case "$repo_status" in
            UPDATED)
                printf "${GREEN}${SYMBOL_SUCCESS}${RESET} %-40s %s\n" "$name" "UPDATED ($message)"
                updated=$((updated + 1))
                ;;
            UPTODATE)
                printf "${BLUE}${SYMBOL_UPTODATE}${RESET} %-40s %s\n" "$name" "UP-TO-DATE"
                uptodate=$((uptodate + 1))
                ;;
            SKIPPED)
                printf "${YELLOW}${SYMBOL_SKIPPED}${RESET} %-40s %s\n" "$name" "SKIPPED ($message)"
                skipped=$((skipped + 1))
                ;;
            ERROR)
                printf "${RED}${SYMBOL_ERROR}${RESET} %-40s %s\n" "$name" "ERROR ($message)"
                errors=$((errors + 1))
                ;;
        esac
    done

    echo ""
    echo "Summary: ${GREEN}${updated} updated${RESET}, ${BLUE}${uptodate} up-to-date${RESET}, ${YELLOW}${skipped} skipped${RESET}, ${RED}${errors} error(s)${RESET}"
}

main
