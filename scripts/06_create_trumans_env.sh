#!/usr/bin/env bash
set -euo pipefail

echo "============================================================"
echo "[INFO] Creating TRUMANS runtime environment"
echo "============================================================"

###############################################################################
# micromamba bootstrap (REQUIRED in non-interactive scripts)
###############################################################################
MAMBA_ROOT_PREFIX="$HOME/scratch/micromamba"
MICROMAMBA_BIN="$MAMBA_ROOT_PREFIX/bin/micromamba"

if [ ! -x "$MICROMAMBA_BIN" ]; then
  echo "[ERROR] micromamba not found at $MICROMAMBA_BIN"
  exit 1
fi

eval "$("$MICROMAMBA_BIN" shell hook --shell bash --root-prefix "$MAMBA_ROOT_PREFIX")"

###############################################################################
# Config
###############################################################################
ENV_NAME="trumans"
PYTHON_VERSION="3.9"

###############################################################################
# Conda-level packages (binary-safe)
###############################################################################
MAMBA_PACKAGES=(
  python=${PYTHON_VERSION}
  numpy=1.26
  scipy
  pillow
  tqdm
  networkx
  pyglet=1.5
)

###############################################################################
# Create environment if it does not exist
###############################################################################
if micromamba env list | awk '{print $1}' | grep -qx "${ENV_NAME}"; then
  echo "[INFO] Environment '${ENV_NAME}' already exists — skipping creation"
else
  echo "[INFO] Creating micromamba environment '${ENV_NAME}'..."
  micromamba create -y -n "${ENV_NAME}" "${MAMBA_PACKAGES[@]}"
fi

###############################################################################
# Activate environment
###############################################################################
echo "[INFO] Activating environment '${ENV_NAME}'..."
micromamba activate "${ENV_NAME}"

###############################################################################
# Pip-level packages (project/runtime deps)
###############################################################################
echo "[INFO] Installing Python packages (pip)..."

pip install --upgrade pip

# Core TRUMANS runtime deps
pip install \
  smplx==0.1.28 \
  trimesh==4.1.8 \
  einops==0.7.0 \
  hydra-core==1.3.2 \
  omegaconf==2.3.0 \
  flask==3.0.0

###############################################################################
# PyTorch (modern CUDA, matches system driver)
###############################################################################
echo "[INFO] Installing PyTorch (CUDA 12.x compatible)..."

pip install \
  torch \
  torchvision \
  torchaudio \
  --index-url https://download.pytorch.org/whl/cu121

###############################################################################
# Sanity check
###############################################################################
echo "[INFO] Running sanity checks..."

python - << 'EOF'
import torch
import smplx
import trimesh

print("Python OK")
print("Torch:", torch.__version__)
print("CUDA available:", torch.cuda.is_available())

# smplx sanity checks
print("SMPL-X module:", smplx)
print("SMPL-X has create():", hasattr(smplx, "create"))
print("SMPL-X file:", smplx.__file__)

print("Trimesh:", trimesh.__version__)
EOF


###############################################################################
# Final message
###############################################################################
echo "============================================================"
echo "✅ TRUMANS environment '${ENV_NAME}' is ready"
echo "➡️  Activate with: micromamba activate ${ENV_NAME}"
echo "📌 Purpose: TRUMANS data loading + motion oracle (NOT training)"
echo "============================================================"
