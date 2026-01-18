#!/usr/bin/env bash
set -euo pipefail

echo "============================================================"
echo "[INFO] Installing SceneMI data into repo (final layout)"
echo "============================================================"

SCRATCH="$HOME/scratch"
ARCHIVE="$SCRATCH/scenemi_data_final.tar.gz"
SCENEMI_ROOT="$SCRATCH/repos/SceneMI"

###############################################################################
# Preconditions
###############################################################################
if [ ! -f "$ARCHIVE" ]; then
  echo "[ERROR] Data archive not found: $ARCHIVE"
  exit 1
fi

if [ ! -d "$SCENEMI_ROOT" ]; then
  echo "[ERROR] SceneMI repo not found: $SCENEMI_ROOT"
  exit 1
fi

###############################################################################
# Clean existing data (idempotent)
###############################################################################
echo "[INFO] Cleaning existing data directories..."

rm -rf "$SCENEMI_ROOT/body_models"
rm -rf "$SCENEMI_ROOT/dataset"

mkdir -p "$SCENEMI_ROOT"

###############################################################################
# Extract directly into repo
###############################################################################
echo "[INFO] Extracting data into SceneMI repo..."

tar -xzf "$ARCHIVE" -C "$SCENEMI_ROOT"

###############################################################################
# Sanity checks
###############################################################################
echo "[INFO] Running sanity checks..."

ls "$SCENEMI_ROOT/body_models/smplx/SMPLX_MALE.npz" >/dev/null
ls "$SCENEMI_ROOT/body_models/smplx/SMPLX_FEMALE.npz" >/dev/null
ls "$SCENEMI_ROOT/body_models/smplx/SMPLX_NEUTRAL.npz" >/dev/null

ls "$SCENEMI_ROOT/datasets/TRUMANS/Data_release" >/dev/null || \
ls "$SCENEMI_ROOT/dataset/TRUMANS/Data_release" >/dev/null

###############################################################################
# Final message
###############################################################################
echo "============================================================"
echo "✅ SceneMI data installed successfully"
echo "📌 Repo: $SCENEMI_ROOT"
echo "📌 SMPL-X: body_models/smplx/"
echo "📌 TRUMANS: dataset/TRUMANS/Data_release/"
echo "➡️  Next step: preprocessing"
echo "============================================================"
