#!/usr/bin/env bash
set -euo pipefail

echo "============================================================"
echo "[UNPACK] Restoring SceneMI preprocessed dataset"
echo "============================================================"

###############################################################################
# Config
###############################################################################
ARCHIVE="/lambda/nfs/SceneMI/preprocess_120_betaFalse.tar.gz"
DEST_DIR="$HOME/scratch/repos/SceneMI"

###############################################################################
# Sanity checks
###############################################################################
if [ ! -f "$ARCHIVE" ]; then
  echo "[ERROR] Archive not found:"
  echo "        $ARCHIVE"
  exit 1
fi

mkdir -p "$DEST_DIR"

echo "[INFO] Archive:"
ls -lh "$ARCHIVE"

echo "[INFO] Destination directory:"
echo "       $DEST_DIR"

###############################################################################
# Extract archive
###############################################################################
echo "------------------------------------------------------------"
echo "[INFO] Extracting archive (this may take a while)..."
echo "------------------------------------------------------------"

tar -xzf "$ARCHIVE" -C "$DEST_DIR"

###############################################################################
# Verification
###############################################################################
echo "------------------------------------------------------------"
echo "[INFO] Verifying extraction..."
echo "------------------------------------------------------------"

EXTRACTED_DIR="${DEST_DIR}/preprocess_120_betaFalse"

if [ ! -d "$EXTRACTED_DIR" ]; then
  echo "[ERROR] Expected directory not found after extraction:"
  echo "        $EXTRACTED_DIR"
  exit 1
fi

du -sh "$EXTRACTED_DIR"

echo "============================================================"
echo "✅ SceneMI preprocessed data restored successfully"
echo "📂 Location: $EXTRACTED_DIR"
echo "============================================================"
