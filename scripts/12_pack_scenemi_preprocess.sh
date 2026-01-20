#!/usr/bin/env bash
set -euo pipefail

echo "============================================================"
echo "[PACK] Zipping SceneMI preprocessed dataset"
echo "============================================================"

###############################################################################
# Config
###############################################################################
SRC_DIR="$HOME/scratch/repos/SceneMI/preprocess_120_betaFalse"
DEST_ROOT="/lambda/nfs/SceneMI"
ARCHIVE_NAME="preprocess_120_betaFalse.tar.gz"
DEST_ARCHIVE="${DEST_ROOT}/${ARCHIVE_NAME}"

###############################################################################
# Sanity checks
###############################################################################
if [ ! -d "$SRC_DIR" ]; then
  echo "[ERROR] Source directory not found:"
  echo "        $SRC_DIR"
  exit 1
fi

mkdir -p "$DEST_ROOT"

echo "[INFO] Source directory:"
du -sh "$SRC_DIR"

echo "[INFO] Destination archive:"
echo "       $DEST_ARCHIVE"

###############################################################################
# Create archive
###############################################################################
echo "------------------------------------------------------------"
echo "[INFO] Creating tar.gz archive (this may take a while)..."
echo "------------------------------------------------------------"

# Use tar + gzip (more robust than zip for huge trees)
tar -C "$(dirname "$SRC_DIR")" \
    -czf "$DEST_ARCHIVE" \
    "$(basename "$SRC_DIR")"

###############################################################################
# Verification
###############################################################################
echo "------------------------------------------------------------"
echo "[INFO] Verifying archive..."
echo "------------------------------------------------------------"

ls -lh "$DEST_ARCHIVE"
du -sh "$DEST_ARCHIVE"

echo "============================================================"
echo "✅ Preprocessed SceneMI data packed successfully"
echo "📦 Archive: $DEST_ARCHIVE"
echo "============================================================"
