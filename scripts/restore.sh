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
ARCHIVE_FILE="$HOME/Downloads/${BACKUP_NAME}"

echo "==> Looking for backup: ${BACKUP_NAME}"
echo ""

# Check rclone is installed
if ! command -v rclone &> /dev/null; then
    echo "ERROR: rclone not found. Install with: brew install rclone"
    exit 1
fi

# Download from B2 if not already present
if [[ -f "$ARCHIVE_FILE" ]]; then
    echo "==> Found local copy: ${ARCHIVE_FILE}"
    echo ""
else
    echo "==> Downloading from Backblaze B2..."
    rclone copy "b2:${BACKUP_NAME}" "$HOME/Downloads/" -P

    if [[ ! -f "$ARCHIVE_FILE" ]]; then
        echo "ERROR: Failed to download ${BACKUP_NAME} from B2"
        exit 1
    fi
    echo ""
fi

# Check 7zz is installed
if ! command -v 7zz &> /dev/null; then
    echo "ERROR: 7zz not found. Install with: brew install 7zip"
    exit 1
fi

# Extract to home directory
echo "==> Extracting archive (enter password when prompted)..."
echo "    Restoring to: $HOME"
echo "    (existing files will be overwritten)"
echo ""
7zz x "$ARCHIVE_FILE" -o"$HOME" -y

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
echo ""
echo "NEXT STEPS:"
echo "  1. Verify restored files"
echo "  2. Delete the archive from ~/Downloads:"
echo "     rm \"${ARCHIVE_FILE}\""
echo ""
