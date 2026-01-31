#!/bin/bash
set -e

# Safety check: only allow restore on backup machine
ALLOWED_HOST="mba.local"
CURRENT_HOST=$(hostname)

if [[ "$CURRENT_HOST" != "$ALLOWED_HOST" ]]; then
    echo "ERROR: Restore script can only run on ${ALLOWED_HOST}"
    echo "       Current host: ${CURRENT_HOST}"
    echo ""
    echo "This prevents accidentally overwriting files on your primary machine."
    exit 1
fi

# Derive backup name from current month and year
MONTH_YEAR=$(date +"%B%Y")
BACKUP_NAME="${MONTH_YEAR}Backup.7z"
EXTERNAL_VOLUME="/Volumes/Backup"
EXTERNAL_ARCHIVE="${EXTERNAL_VOLUME}/${BACKUP_NAME}"
LOCAL_ARCHIVE="$HOME/Downloads/${BACKUP_NAME}"

echo "==> Looking for backup: ${BACKUP_NAME}"
echo ""

# Check if external backup drive is connected and has the current backup
if [[ -f "$EXTERNAL_ARCHIVE" ]]; then
    echo "==> Found on external drive: ${EXTERNAL_ARCHIVE}"
    ARCHIVE_FILE="$EXTERNAL_ARCHIVE"
    echo ""
# Check if already downloaded locally
elif [[ -f "$LOCAL_ARCHIVE" ]]; then
    echo "==> Found local copy: ${LOCAL_ARCHIVE}"
    ARCHIVE_FILE="$LOCAL_ARCHIVE"
    echo ""
# Otherwise download from B2
else
    # Check rclone is installed
    if ! command -v rclone &> /dev/null; then
        echo "ERROR: rclone not found. Install with: brew install rclone"
        exit 1
    fi

    echo "==> Downloading from Backblaze B2..."
    rclone copy "b2:${BACKUP_NAME}" "$HOME/Downloads/" -P

    if [[ ! -f "$LOCAL_ARCHIVE" ]]; then
        echo "ERROR: Failed to download ${BACKUP_NAME} from B2"
        exit 1
    fi
    ARCHIVE_FILE="$LOCAL_ARCHIVE"
    echo ""
fi

# Check 7zz is installed
if ! command -v 7zz &> /dev/null; then
    echo "ERROR: 7zz not found. Install with: brew install 7zip"
    exit 1
fi

# Extract to home directory
echo "==> Extracting archive..."
echo "    Restoring to: $HOME"
echo "    (existing files will be overwritten)"
echo ""

# Prompt for password securely
read -s -p "Enter password: " PASSWORD
echo ""
echo ""

7zz x -p"$PASSWORD" "$ARCHIVE_FILE" -o"$HOME" -y

unset PASSWORD

# Done
echo ""
echo "========================================"
echo "Restore complete!"
echo "========================================"
echo ""
echo "Restored to:"
echo "  ~/Documents"
echo "  ~/Google Drive"
echo "  ~/Library/Mail"
echo "  ~/Sources"
echo ""
echo "NEXT STEPS:"
echo "  1. Verify restored files"
if [[ "$ARCHIVE_FILE" == "$LOCAL_ARCHIVE" ]]; then
    echo "  2. Delete the archive from ~/Downloads:"
    echo "     rm \"${ARCHIVE_FILE}\""
else
    echo "  2. Archive used from external drive (no cleanup needed)"
fi
echo ""
