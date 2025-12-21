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

# Find 7z files in ~/Downloads
ARCHIVE_FILES=(~/Downloads/*.7z)

# Check if glob matched anything
if [[ ! -e "${ARCHIVE_FILES[0]}" ]]; then
    echo "ERROR: No .7z files found in ~/Downloads"
    exit 1
fi

# Check for exactly one archive
if [[ ${#ARCHIVE_FILES[@]} -gt 1 ]]; then
    echo "ERROR: Multiple .7z files found in ~/Downloads:"
    printf "       %s\n" "${ARCHIVE_FILES[@]}"
    echo ""
    echo "Please ensure only one .7z file exists and try again."
    exit 1
fi

ARCHIVE_FILE="${ARCHIVE_FILES[0]}"
echo "==> Found backup: $(basename "$ARCHIVE_FILE")"
echo ""

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
