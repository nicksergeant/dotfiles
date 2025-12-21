#!/bin/bash
set -e

# Find DMG files in ~/Downloads
DMG_FILES=(~/Downloads/*.dmg)

# Check if glob matched anything
if [[ ! -e "${DMG_FILES[0]}" ]]; then
    echo "ERROR: No .dmg files found in ~/Downloads"
    exit 1
fi

# Check for exactly one DMG
if [[ ${#DMG_FILES[@]} -gt 1 ]]; then
    echo "ERROR: Multiple .dmg files found in ~/Downloads:"
    printf "       %s\n" "${DMG_FILES[@]}"
    echo ""
    echo "Please ensure only one .dmg file exists and try again."
    exit 1
fi

DMG_FILE="${DMG_FILES[0]}"
echo "==> Found backup: $(basename "$DMG_FILE")"
echo ""

# Mount the encrypted DMG (will prompt for password)
echo "==> Mounting DMG (enter password when prompted)..."
MOUNT_OUTPUT=$(hdiutil attach "$DMG_FILE" -nobrowse)
MOUNT_POINT=$(echo "$MOUNT_OUTPUT" | grep -o '/Volumes/.*' | head -1)

if [[ -z "$MOUNT_POINT" ]]; then
    echo "ERROR: Failed to mount DMG"
    exit 1
fi

echo "    Mounted at: ${MOUNT_POINT}"
echo ""

# Restore destinations
RESTORE_BASE="$HOME/Restored"
RESTORE_DOCS="${RESTORE_BASE}/Documents"
RESTORE_GDRIVE="${RESTORE_BASE}/Google Drive"

# Create restore directories
mkdir -p "$RESTORE_DOCS"
mkdir -p "$RESTORE_GDRIVE"

# Restore Documents
if [[ -d "${MOUNT_POINT}/Documents" ]]; then
    echo "==> Restoring Documents..."
    rsync -aP "${MOUNT_POINT}/Documents/" "$RESTORE_DOCS/"
else
    echo "WARNING: Documents not found in backup, skipping."
fi

# Restore Google Drive
if [[ -d "${MOUNT_POINT}/Google Drive" ]]; then
    echo ""
    echo "==> Restoring Google Drive..."
    rsync -aP "${MOUNT_POINT}/Google Drive/" "$RESTORE_GDRIVE/"
else
    echo "WARNING: Google Drive not found in backup, skipping."
fi

# Unmount
echo ""
echo "==> Unmounting DMG..."
hdiutil eject "$MOUNT_POINT"

# Done
echo ""
echo "========================================"
echo "Restore complete!"
echo "========================================"
echo ""
echo "Restored to:"
echo "  ${RESTORE_DOCS}"
echo "  ${RESTORE_GDRIVE}"
echo ""
echo "NEXT STEPS:"
echo "  1. Verify restored files"
echo "  2. Move to final locations if desired"
echo "  3. Delete the DMG from ~/Downloads:"
echo "     rm \"${DMG_FILE}\""
echo ""
