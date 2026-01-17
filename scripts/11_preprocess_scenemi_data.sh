#!/usr/bin/env bash
set -euo pipefail

echo "============================================================"
echo "[INFO] Preprocessing SceneMI dataset"
echo "============================================================"

###############################################################################
# micromamba bootstrap
###############################################################################
MAMBA_ROOT_PREFIX="$HOME/scratch/micromamba"
MICROMAMBA_BIN="$MAMBA_ROOT_PREFIX/bin/micromamba"

if [ ! -x "$MICROMAMBA_BIN" ]; then
  echo "[ERROR] micromamba not found at $MICROMAMBA_BIN"
  exit 1
fi

eval "$("$MICROMAMBA_BIN" shell hook --shell bash --root-prefix "$MAMBA_ROOT_PREFIX")"

###############################################################################
# Activate SceneMI environment
###############################################################################
ENV_NAME="scenemi"
echo "[INFO] Activating environment '${ENV_NAME}'..."
micromamba activate "${ENV_NAME}"

###############################################################################
# Paths (do NOT assume bashrc is sourced)
###############################################################################
SCENEMI_ROOT="$HOME/scratch/repos/SceneMI"
SMPLX_MODEL_PATH="$HOME/scratch/body_models/smplx"
TRUMANS_DATA_ROOT="$HOME/scratch/datasets/TRUMANS/Data_release"

###############################################################################
# Sanity checks: code
###############################################################################
if [ ! -d "$SCENEMI_ROOT" ]; then
  echo "[ERROR] SceneMI repo not found at $SCENEMI_ROOT"
  exit 1
fi

###############################################################################
# Sanity checks: assets
###############################################################################
echo "[INFO] Checking SMPL-X models..."
if [ ! -d "$SMPLX_MODEL_PATH" ]; then
  echo "[ERROR] SMPL-X models not found at $SMPLX_MODEL_PATH"
  exit 1
fi

echo "[INFO] Checking TRUMANS dataset..."
if [ ! -d "$TRUMANS_DATA_ROOT" ]; then
  echo "[ERROR] TRUMANS dataset not found at $TRUMANS_DATA_ROOT"
  exit 1
fi

###############################################################################
# Export env vars for SceneMI (local to this script)
###############################################################################
export SMPLX_MODEL_PATH
export TRUMANS_DATA_ROOT

###############################################################################
# Run preprocessing
###############################################################################
echo "------------------------------------------------------------"
echo "[INFO] Running preprocess_dataset.py"
echo "------------------------------------------------------------"

cd "$SCENEMI_ROOT"

export PYTHONPATH="$SCENEMI_ROOT:$SCENEMI_ROOT/utils:${PYTHONPATH:-}"

python "preprocess_dataset.py"

###############################################################################
# Post-checks (best-effort, non-strict)
###############################################################################
echo "------------------------------------------------------------"
echo "[INFO] Post-preprocessing checks"
echo "------------------------------------------------------------"

if [ -d "$SCENEMI_ROOT/dataset" ]; then
  echo "[OK] dataset/ directory created"
  find "$SCENEMI_ROOT/dataset" -maxdepth 2 -type d | head -n 20
else
  echo "[WARN] dataset/ directory not found — check preprocess output"
fi

###############################################################################
# Final message
###############################################################################
echo "============================================================"
echo "✅ SceneMI preprocessing completed"
echo "📌 Repo: $SCENEMI_ROOT"
echo "📌 SMPL-X: $SMPLX_MODEL_PATH"
echo "📌 TRUMANS: $TRUMANS_DATA_ROOT"
echo "➡️  Next step: training sanity run"
echo "============================================================"
