#!/usr/bin/env bash
set -euo pipefail

echo "============================================================"
echo "[INFO] Packing SceneMI assets on macOS"
echo "============================================================"

# Base data dir on Mac
MAC_DATA_ROOT="/Users/songxiran/data"

# Output
OUT_DIR="$HOME/scenemi_transfer"
ARCHIVE="$OUT_DIR/scenemi_assets.tar.gz"

mkdir -p "$OUT_DIR"

###############################################################################
# Prepare staging directory
###############################################################################
STAGING="$OUT_DIR/staging"
rm -rf "$STAGING"
mkdir -p "$STAGING/body_models"
mkdir -p "$STAGING/datasets/TRUMANS/Data_release"

###############################################################################
# SMPL-X
###############################################################################
echo "[INFO] Adding SMPL-X models..."
unzip -q "$MAC_DATA_ROOT/models_smplx_v1_1.zip" -d "$STAGING/body_models/smplx"

###############################################################################
# TRUMANS (partial)
###############################################################################
echo "[INFO] Adding TRUMANS partial dataset..."

TRUMANS_SRC="$MAC_DATA_ROOT/TRUMANS/Data_release"

cp -v "$TRUMANS_SRC"/*.npy "$STAGING/datasets/TRUMANS/Data_release/" || true

for z in \
  Scene_mesh-*.zip \
  Scene_occ_render-*.zip \
  Scene-*.zip \
  Object_all-*.zip \
  Object_chairs-*.zip
do
  unzip -q "$TRUMANS_SRC/$z" -d "$STAGING/datasets/TRUMANS/Data_release/"
done

###############################################################################
# Pack
###############################################################################
echo "[INFO] Creating archive..."
tar -czf "$ARCHIVE" -C "$STAGING" .

echo "============================================================"
echo "✅ SceneMI assets packed"
echo "📦 Archive: $ARCHIVE"
echo "============================================================"
