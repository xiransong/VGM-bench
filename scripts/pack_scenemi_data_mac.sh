#!/usr/bin/env bash
set -euo pipefail

echo "============================================================"
echo "[INFO] Packing SceneMI data from staging directory (macOS)"
echo "============================================================"

STAGING="$HOME/scenemi_transfer/staging"
OUT_DIR="$HOME/scenemi_transfer"
ARCHIVE="$OUT_DIR/scenemi_data_final.tar.gz"

if [ ! -d "$STAGING" ]; then
  echo "[ERROR] Staging directory not found: $STAGING"
  exit 1
fi

###############################################################################
# Sanity checks
###############################################################################
echo "[INFO] Running sanity checks..."

ls "$STAGING/body_models/smplx/SMPLX_MALE.npz" >/dev/null
ls "$STAGING/body_models/smplx/SMPLX_FEMALE.npz" >/dev/null
ls "$STAGING/body_models/smplx/SMPLX_NEUTRAL.npz" >/dev/null
ls "$STAGING/datasets/TRUMANS/Data_release" >/dev/null

###############################################################################
# Pack
###############################################################################
echo "[INFO] Creating tarball..."
tar -czf "$ARCHIVE" -C "$STAGING" .

echo "============================================================"
echo "✅ SceneMI data packed successfully"
echo "📦 Archive: $ARCHIVE"
echo "============================================================"
