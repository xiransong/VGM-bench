#!/usr/bin/env bash
set -euo pipefail

echo "============================================================"
echo "[PACK] SceneMI preprocess → Lambda FS (NO compression)"
echo "============================================================"

###############################################################################
# Configuration
###############################################################################
SRC_DIR="$HOME/scratch/repos/SceneMI/preprocess_120_betaFalse"
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
echo "[INFO] Checking source directory..."
test -d "$SRC_DIR" || { echo "[ERROR] Source dir not found: $SRC_DIR"; exit 1; }

echo "[INFO] Checking Lambda FS..."
test -d "$LAMBDA_FS" || { echo "[ERROR] Lambda FS not found: $LAMBDA_FS"; exit 1; }

###############################################################################
# Create tar archive (NO compression)
###############################################################################
echo "[INFO] Creating tar archive locally on scratch disk..."
rm -f "$LOCAL_TAR" "$LOCAL_SHA"

tar -C "$(dirname "$SRC_DIR")" \
    -cf "$LOCAL_TAR" \
    "$(basename "$SRC_DIR")"

echo "[INFO] Tar created:"
ls -lh "$LOCAL_TAR"

###############################################################################
# Generate checksum
###############################################################################
echo "[INFO] Generating SHA256 checksum..."
sha256sum "$LOCAL_TAR" > "$LOCAL_SHA"
cat "$LOCAL_SHA"

###############################################################################
# Copy to Lambda FS
###############################################################################
echo "[INFO] Copying archive to Lambda FS..."
cp "$LOCAL_TAR" "$REMOTE_TAR"
cp "$LOCAL_SHA" "$REMOTE_SHA"

###############################################################################
# Verify checksum on Lambda FS
###############################################################################
echo "[INFO] Verifying checksum on Lambda FS..."
(
  cd "$LAMBDA_FS"
  sha256sum -c "$(basename "$REMOTE_SHA")"
)

echo "============================================================"
echo "✅ Pack & upload completed successfully"
echo "📦 Archive: $REMOTE_TAR"
echo "============================================================"
