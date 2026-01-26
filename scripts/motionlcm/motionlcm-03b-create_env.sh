#!/usr/bin/env bash
set -euo pipefail

echo "============================================================"
echo "[MotionLCM] Creating isolated MotionLCM environment"
echo "============================================================"

###############################################################################
# micromamba bootstrap
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
ENV_NAME="motionlcm"
PYTHON_VERSION="3.10"

###############################################################################
# Create environment (if needed)
###############################################################################
if micromamba env list | awk '{print $1}' | grep -qx "${ENV_NAME}"; then
  echo "[INFO] Environment '${ENV_NAME}' already exists — skipping creation"
else
  echo "[INFO] Creating micromamba environment '${ENV_NAME}'..."
  micromamba create -y -n "${ENV_NAME}" python=${PYTHON_VERSION}
fi

###############################################################################
# Activate environment
###############################################################################
echo "[INFO] Activating environment '${ENV_NAME}'..."
micromamba activate "${ENV_NAME}"

###############################################################################
# Install PyTorch (official wheels, CUDA runtime via wheel)
###############################################################################
echo "[INFO] Installing PyTorch 1.13.1 (CUDA-enabled)..."

pip install --upgrade pip

# Numerical stack
pip install numpy==1.23.5 scipy

# Vision utils
pip install opencv-python==4.7.0.72 imageio matplotlib

# PyTorch
pip install \
  torch==1.13.1+cu117 \
  torchvision==0.14.1+cu117 \
  torchaudio==0.13.1 \
  --extra-index-url https://download.pytorch.org/whl/cu117

# HF + diffusion stack
pip install \
  huggingface_hub==0.19.4 \
  diffusers==0.24.0 \
  accelerate==0.21.0 \
  transformers==4.35.2 \
  --no-deps

pip install torchmetrics==0.7.3 tensorboard

###############################################################################
# Sanity check: CUDA availability
###############################################################################
echo "[INFO] Verifying PyTorch CUDA support..."
python - << 'EOF'
import torch
print("PyTorch:", torch.__version__)
print("CUDA available:", torch.cuda.is_available())
if torch.cuda.is_available():
    print("CUDA version:", torch.version.cuda)
    print("GPU:", torch.cuda.get_device_name(0))
EOF

###############################################################################
# Install MotionLCM Python dependencies (minimal, inference-focused)
###############################################################################
echo "[INFO] Installing MotionLCM Python dependencies..."

pip install \
  numpy \
  scipy \
  tqdm \
  pyyaml \
  einops \
  loguru \
  rich \
  opencv-python \
  imageio \
  matplotlib \
  gdown \
  omegaconf \
  hydra-core

###############################################################################
# Final message
###############################################################################
echo "============================================================"
echo "✅ MotionLCM environment '${ENV_NAME}' is ready"
echo "➡️  Activate with: micromamba activate ${ENV_NAME}"
echo "============================================================"
