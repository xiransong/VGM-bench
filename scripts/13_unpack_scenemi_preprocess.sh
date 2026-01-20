#!/usr/bin/env bash
set -euo pipefail

echo "============================================================"
echo "[UNPACK] SceneMI preprocess ← Lambda FS (NO compression)"
echo "============================================================"

###############################################################################
# Configuration
###############################################################################
SCRATCH_DIR="$HOME/scratch"
LAMBDA_FS="/lambda/nfs/SceneMI"

ARCHIVE_NAME="preprocess_120_betaFalse.tar"
LOCAL_TAR="${SCRATCH_DIR}/${ARCHIVE_NAME}"
LOCAL_SHA="${LOCAL_TAR}.sha256"

REMOTE_TAR="${LAMBDA_FS}/${ARCHIVE_NAME}"
REMOTE_SHA="${REMOTE_TAR}.sha256"

###############################################################################
# Sanity checks
###############################################################################
echo "[INFO] Checking Lambda FS files..."
test -f "$REMOTE_TAR" || { echo "[ERROR] Archive not found: $REMOTE_TAR"; exit 1; }
test -f "$REMOTE_SHA" || { echo "[ERROR] Checksum not found: $REMOTE_SHA"; exit 1; }

###############################################################################
# Copy from Lambda FS to scratch
###############################################################################
echo "[INFO] Copying archive to local scratch..."
cp "$REMOTE_TAR" "$LOCAL_TAR"
cp "$REMOTE_SHA" "$LOCAL_SHA"

###############################################################################
# Verify checksum locally
###############################################################################
echo "[INFO] Verifying checksum on scratch disk..."
(
  cd "$SCRATCH_DIR"
  sha256sum -c "$(basename "$LOCAL_SHA")"
)

###############################################################################
# Extract archive
###############################################################################
echo "[INFO] Extracting tar archive..."
tar -C "$SCRATCH_DIR" -xf "$LOCAL_TAR"

echo "[INFO] Extraction completed:"
ls -lh "$SCRATCH_DIR/preprocess_120_betaFalse"

echo "============================================================"
echo "✅ Unpack completed successfully"
echo "============================================================"
