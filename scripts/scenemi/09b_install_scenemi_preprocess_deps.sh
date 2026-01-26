#!/usr/bin/env bash
set -euo pipefail

echo "============================================================"
echo "[INFO] Installing SceneMI preprocessing dependencies"
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
# Activate env
###############################################################################
ENV_NAME="scenemi"
echo "[INFO] Activating environment '${ENV_NAME}'..."
micromamba activate "${ENV_NAME}"

###############################################################################
# Install preprocessing-only deps
###############################################################################
echo "[INFO] Installing SceneMI preprocessing dependencies..."

pip install \
  open3d==0.18.0 \
  scikit-image==0.20.0 \
  git+https://github.com/nghorbani/human_body_prior.git@4c246d8a83ce16d3cff9c79dcf04d81fa440a6bc \
  git+https://github.com/otaheri/chamfer_distance.git@f86f6f7cadd3aca642704573d1626c67ca2e2846

###############################################################################
# Sanity check
###############################################################################
python - << 'EOF'
import open3d
import skimage.measure
print("SceneMI preprocessing dependency OK")
EOF

###############################################################################
# Final message
###############################################################################
echo "============================================================"
echo "✅ SceneMI preprocessing dependencies installed"
echo "➡️  Re-run: bash 11_preprocess_scenemi_data.sh"
echo "============================================================"
