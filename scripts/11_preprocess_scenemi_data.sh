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
# Run preprocessing
###############################################################################
echo "------------------------------------------------------------"
echo "[INFO] Running preprocess_dataset.py"
echo "------------------------------------------------------------"

SCENEMI_ROOT="$HOME/scratch/repos/SceneMI"

cd "$SCENEMI_ROOT"

export PYTHONPATH="$SCENEMI_ROOT:$SCENEMI_ROOT/utils:${PYTHONPATH:-}"

python "preprocess_dataset.py"

###############################################################################
# Final message
###############################################################################
echo "============================================================"
echo "✅ SceneMI preprocessing completed"
echo "➡️  Next step: training sanity run"
echo "============================================================"
