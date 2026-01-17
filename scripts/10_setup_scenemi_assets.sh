#!/usr/bin/env bash
set -euo pipefail

echo "============================================================"
echo "[INFO] Setting up SceneMI assets (with repo-local symlinks)"
echo "============================================================"

SCRATCH="$HOME/scratch"
ARCHIVE="$SCRATCH/scenemi_assets.tar.gz"
SCENEMI_ROOT="$SCRATCH/repos/SceneMI"

###############################################################################
# Check inputs
###############################################################################
if [ ! -f "$ARCHIVE" ]; then
  echo "[ERROR] Asset archive not found: $ARCHIVE"
  exit 1
fi

if [ ! -d "$SCENEMI_ROOT" ]; then
  echo "[ERROR] SceneMI repo not found at: $SCENEMI_ROOT"
  exit 1
fi

###############################################################################
# Extract assets into scratch
###############################################################################
echo "[INFO] Extracting assets into $SCRATCH ..."
tar -xzf "$ARCHIVE" -C "$SCRATCH"

###############################################################################
# Create repo-local symlinks (SceneMI expects relative paths)
###############################################################################
echo "[INFO] Creating repo-local symlinks..."

cd "$SCENEMI_ROOT"

# --- SMPL-X models (repo expects ./body_models) ---
rm -rf body_models
ln -s "$SCRATCH/body_models" body_models

# --- TRUMANS dataset (repo expects ./dataset/TRUMANS) ---
rm -rf dataset
mkdir -p dataset
ln -s "$SCRATCH/datasets/TRUMANS" dataset/TRUMANS

###############################################################################
# SMPL-X compatibility symlinks (SceneMI expects flat layout)
###############################################################################
echo "[INFO] Creating SMPL-X compatibility symlinks..."

SMPLX_SRC="$SCRATCH/body_models/smplx/models/smplx"
SMPLX_DST="$SCENEMI_ROOT/body_models/smplx"

mkdir -p "$SMPLX_DST"

for f in SMPLX_MALE.npz SMPLX_FEMALE.npz SMPLX_NEUTRAL.npz; do
  rm -f "$SMPLX_DST/$f"
  ln -s "$SMPLX_SRC/$f" "$SMPLX_DST/$f"
done

###############################################################################
# Sanity checks
###############################################################################
echo "[INFO] Running sanity checks..."

ls body_models/smplx/models/smplx >/dev/null
ls dataset/TRUMANS/Data_release >/dev/null

###############################################################################
# Final message
###############################################################################
echo "============================================================"
echo "✅ SceneMI assets installed and linked correctly"
echo "📌 SMPL-X (repo): $SCENEMI_ROOT/body_models"
echo "📌 TRUMANS (repo): $SCENEMI_ROOT/dataset/TRUMANS"
echo "➡️  Next step: preprocessing"
echo "============================================================"
