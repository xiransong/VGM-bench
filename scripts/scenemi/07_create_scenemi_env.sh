#!/usr/bin/env bash
set -euo pipefail

echo "============================================================"
echo "[INFO] Creating SceneMI training environment"
echo "============================================================"

###############################################################################
# micromamba bootstrap (REQUIRED in non-interactive scripts)
###############################################################################
MAMBA_ROOT_PREFIX="$HOME/scratch/micromamba"
MICROMAMBA_BIN="$MAMBA_ROOT_PREFIX/bin/micromamba"

if [ ! -x "$MICROMAMBA_BIN" ]; then
  echo "[ERROR] micromamba not found at $MICROMAMBA_BIN"
  echo "        Did you run 02_install_micromamba.sh?"
  exit 1
fi

eval "$("$MICROMAMBA_BIN" shell hook --shell bash --root-prefix "$MAMBA_ROOT_PREFIX")"

###############################################################################
# Config
###############################################################################
ENV_NAME="scenemi"
PYTHON_VERSION="3.9"

###############################################################################
# Conda / micromamba-level packages
# (binary-sensitive, compilation-heavy, or system-coupled)
###############################################################################
MAMBA_PACKAGES=(
  python=${PYTHON_VERSION}

  # Core scientific stack
  numpy=1.24
  scipy
  pandas

  # Build & compilation tools (required by pytorch3d, chamfer_distance)
  cmake
  ninja
  gcc
  gxx

  # Geometry / graphics runtime safety
  pyglet=1.5
  ffmpeg
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
# Upgrade pip (ALWAYS do this explicitly)
###############################################################################
echo "[INFO] Upgrading pip..."
pip install --upgrade pip setuptools wheel

###############################################################################
# PyTorch (CUDA-native, matches system driver)
# NOTE:
# - We intentionally do NOT pin to torch==1.12.1+cu113
# - Training works fine on newer CUDA with sufficient GPUs
###############################################################################
echo "[INFO] Installing PyTorch (CUDA-native)..."

pip install \
  torch \
  torchvision \
  torchaudio \
  --index-url https://download.pytorch.org/whl/cu121

###############################################################################
# Core SceneMI training dependencies (Tier 1)
###############################################################################
echo "[INFO] Installing core SceneMI training dependencies..."

pip install \
  pytorch-lightning==1.4.2 \
  diffusers==0.24.0 \
  einops==0.7.0 \
  hydra-core==1.3.2 \
  omegaconf==2.3.0 \
  smplx==0.1.28 \
  trimesh==4.1.8 \
  loguru \
  tqdm \
  matplotlib==3.5.0 \
  pillow \
  pyyaml

###############################################################################
# Sanity checks
###############################################################################
echo "[INFO] Running environment sanity checks..."

python - << 'EOF'
import sys
import torch
import numpy
import scipy
import trimesh
import smplx

print("Python:", sys.version)
print("Torch:", torch.__version__)
print("CUDA available:", torch.cuda.is_available())
print("NumPy:", numpy.__version__)
print("SciPy:", scipy.__version__)
print("Trimesh:", trimesh.__version__)
print("SMPL-X module:", smplx)

if not torch.cuda.is_available():
    raise RuntimeError("CUDA is NOT available — check NVIDIA driver / PyTorch install")

print("SceneMI base environment sanity check PASSED")
EOF

###############################################################################
# Final message
###############################################################################
echo "============================================================"
echo "✅ SceneMI environment '${ENV_NAME}' is ready"
echo "➡️  Activate with: micromamba activate ${ENV_NAME}"
echo "📌 Purpose: Full SceneMI training + preprocessing + inference"
echo "============================================================"
