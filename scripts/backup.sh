#!/bin/bash
set -e

# Confirm 1Password exports
echo "Have you exported both 1Password vaults to ~/Documents? (y/n)"
read -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Please export your 1Password vaults first, then re-run."
    exit 1
fi

# Derive backup name from current month and year
MONTH_YEAR=$(date +"%B%Y")
BACKUP_NAME="${MONTH_YEAR}Backup"

# Source directories
SOURCE_DIRS=(
    "$HOME/Documents"
    "$HOME/Google Drive"
    "$HOME/Library/Mail"
    "$HOME/Sources"
)

# Paths
EXTERNAL_VOLUME="/Volumes/Backup"
FINAL_ARCHIVE="${EXTERNAL_VOLUME}/${BACKUP_NAME}.7z"

echo "==> Creating backup: ${BACKUP_NAME}"
echo ""

# Calculate total size
echo "==> Calculating source size..."
TOTAL_KB=0
for dir in "${SOURCE_DIRS[@]}"; do
    if [[ -d "$dir" ]]; then
        DIR_KB=$(du -sk "$dir" 2>/dev/null | cut -f1)
        TOTAL_KB=$((TOTAL_KB + DIR_KB))
        echo "    $(basename "$dir"): $((DIR_KB / 1024 / 1024))GB"
    else
        echo "    WARNING: $dir does not exist, skipping."
    fi
done
TOTAL_GB=$((TOTAL_KB / 1024 / 1024))
echo "    Total: ${TOTAL_GB}GB"
echo ""

# Check external volume is mounted
if [[ ! -d "$EXTERNAL_VOLUME" ]]; then
    echo "ERROR: External volume not mounted at ${EXTERNAL_VOLUME}"
    echo "       Please connect and mount your backup drive."
    exit 1
fi

# Check available disk space on external volume
AVAILABLE_KB=$(df -k "$EXTERNAL_VOLUME" | tail -1 | awk '{print $4}')
AVAILABLE_GB=$((AVAILABLE_KB / 1024 / 1024))
echo "==> Checking disk space on ${EXTERNAL_VOLUME}..."
echo "    Available: ${AVAILABLE_GB}GB"
echo "    Required:  ~${TOTAL_GB}GB (likely less after compression)"
echo ""

if [[ $AVAILABLE_GB -lt $TOTAL_GB ]]; then
    echo "ERROR: Not enough disk space on external volume."
    echo "       Need ${TOTAL_GB}GB but only ${AVAILABLE_GB}GB available."
    exit 1
fi

# Check if archive already exists
if [[ -e "$FINAL_ARCHIVE" ]]; then
    echo "WARNING: ${FINAL_ARCHIVE} already exists."
    read -p "Overwrite? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborting."
        exit 1
    fi
    rm "$FINAL_ARCHIVE"
fi

# Check 7zz is installed
if ! command -v 7zz &> /dev/null; then
    echo "ERROR: 7zz not found. Install with: brew install 7zip"
    exit 1
fi

# Build list of existing source directories
SOURCES_TO_BACKUP=()
for dir in "${SOURCE_DIRS[@]}"; do
    if [[ -d "$dir" ]]; then
        SOURCES_TO_BACKUP+=("$dir")
    fi
done

# Create encrypted, compressed archive
echo "==> Creating encrypted archive..."
echo "    (excluding node_modules, .git, __pycache__, .venv)"
echo ""

# Prompt for password securely
read -s -p "Enter password: " PASSWORD
echo ""
read -s -p "Confirm password: " PASSWORD_CONFIRM
echo ""

if [[ "$PASSWORD" != "$PASSWORD_CONFIRM" ]]; then
    echo "ERROR: Passwords do not match."
    exit 1
fi

7zz a -p"$PASSWORD" -mhe=on \
    -xr!node_modules \
    -xr!.git \
    -xr!__pycache__ \
    -xr!.venv \
    "$FINAL_ARCHIVE" "${SOURCES_TO_BACKUP[@]}"

EXITCODE=$?
unset PASSWORD PASSWORD_CONFIRM

# 7zip exit codes: 0=success, 1=warning (non-fatal), 2+=fatal error
if [[ $EXITCODE -ge 2 ]]; then
    echo "ERROR: 7zip failed with exit code $EXITCODE"
    exit 1
fi

# Upload to Backblaze B2
echo ""
echo "==> Uploading to Backblaze B2..."
rclone copy "$FINAL_ARCHIVE" b2: -P

# Done
echo ""
echo "========================================"
echo "Backup complete!"
echo "========================================"
echo ""
echo "Uploaded: ${FINAL_ARCHIVE}"
echo ""
echo "NEXT STEPS:"
echo "  1. Verify upload in B2 console"
echo "  2. Delete local backup:"
echo "     rm ${FINAL_ARCHIVE}"
echo ""
