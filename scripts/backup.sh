#!/bin/bash
set -e

# Derive volume name from current month and year
MONTH_YEAR=$(date +"%B%Y")
VOLUME_NAME="${MONTH_YEAR}Backup"

# Source directories
SOURCE_DIRS=(
    "$HOME/Documents"
    "$HOME/Google Drive"
)

# Paths
EXTERNAL_VOLUME="/Volumes/Backup"
TMP_IMAGE="${EXTERNAL_VOLUME}/backup_temp.sparseimage"
FINAL_DMG="${EXTERNAL_VOLUME}/${VOLUME_NAME}.dmg"
MOUNT_POINT="/Volumes/${VOLUME_NAME}"

echo "==> Creating backup: ${VOLUME_NAME}"
echo ""

# Calculate required size with 20% buffer
echo "==> Calculating required size..."
TOTAL_BYTES=0
for dir in "${SOURCE_DIRS[@]}"; do
    if [[ -d "$dir" ]]; then
        DIR_BYTES=$(du -sk "$dir" 2>/dev/null | cut -f1)
        TOTAL_BYTES=$((TOTAL_BYTES + DIR_BYTES))
        echo "    $(basename "$dir"): $((DIR_BYTES / 1024 / 1024))GB"
    else
        echo "    WARNING: $dir does not exist, skipping."
    fi
done

# Add 20% buffer and convert to GB (rounded up)
BUFFER_BYTES=$((TOTAL_BYTES * 120 / 100))
SIZE_GB=$(( (BUFFER_BYTES / 1024 / 1024) + 1 ))
echo "    Total with 20% buffer: ${SIZE_GB}GB"
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
echo "    Required:  ${SIZE_GB}GB"
echo ""

if [[ $AVAILABLE_GB -lt $SIZE_GB ]]; then
    echo "ERROR: Not enough disk space on external volume."
    echo "       Need ${SIZE_GB}GB but only ${AVAILABLE_GB}GB available."
    exit 1
fi

# Check if temp image already exists
if [[ -f "$TMP_IMAGE" ]]; then
    echo "Removing existing temp image..."
    rm "$TMP_IMAGE"
fi

# Check if final DMG already exists
if [[ -f "$FINAL_DMG" ]]; then
    echo "WARNING: ${FINAL_DMG} already exists."
    read -p "Overwrite? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborting."
        exit 1
    fi
    rm "$FINAL_DMG"
fi

# 1. Create temp writable sparse image
echo "==> Creating temporary sparse image..."
hdiutil create -size "${SIZE_GB}g" -type SPARSE -fs APFS \
    -volname "$VOLUME_NAME" "$TMP_IMAGE"

# 2. Mount it
echo ""
echo "==> Mounting image..."
hdiutil attach "$TMP_IMAGE"

# 3. Copy directories with rsync
for dir in "${SOURCE_DIRS[@]}"; do
    if [[ -d "$dir" ]]; then
        echo ""
        echo "==> Copying $(basename "$dir")..."
        rsync -aP "$dir" "$MOUNT_POINT/"
    fi
done

# 4. Eject
echo ""
echo "==> Ejecting..."
hdiutil eject "$MOUNT_POINT"

# 5. Convert to compressed + encrypted DMG
echo ""
echo "==> Converting to compressed, encrypted DMG..."
echo "    You will be prompted to set a password."
hdiutil convert "$TMP_IMAGE" \
    -format UDZO -encryption AES-256 \
    -o "$FINAL_DMG"

# 6. Clean up temp file
echo ""
echo "==> Cleaning up temp files..."
rm "$TMP_IMAGE"

# Done
echo ""
echo "========================================"
echo "Backup complete!"
echo "========================================"
echo ""
echo "Final DMG: ${FINAL_DMG}"
echo ""
echo "NEXT STEPS:"
echo "  1. Upload to Backblaze B2:"
echo "     b2 upload-file <bucket-name> ${FINAL_DMG} ${VOLUME_NAME}.dmg"
echo ""
echo "  2. Delete local backup after upload:"
echo "     rm ${FINAL_DMG}"
echo ""
