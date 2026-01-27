#!/usr/bin/env bash
set -e

echo "============================================================"
echo "[MotionLCM] Creating MotionLCM environment (Docker-safe)"
echo "============================================================"

###############################################################################
# Config (fixed paths, no shell activation)
###############################################################################
MAMBA_ROOT_PREFIX="/opt/micromamba"
MICROMAMBA_BIN="${MAMBA_ROOT_PREFIX}/bin/micromamba"
ENV_PREFIX="${MAMBA_ROOT_PREFIX}/envs/motionlcm"
PYTHON_VERSION="3.10"

if [ ! -x "$MICROMAMBA_BIN" ]; then
  echo "[ERROR] micromamba not found at $MICROMAMBA_BIN"
  exit 1
fi

###############################################################################
# Create environment
###############################################################################
echo "[INFO] Creating micromamba env at ${ENV_PREFIX} ..."
"$MICROMAMBA_BIN" create -y -p "${ENV_PREFIX}" python=${PYTHON_VERSION}

###############################################################################
# Upgrade pip
###############################################################################
"$MICROMAMBA_BIN" run -p "${ENV_PREFIX}" \
  python -m pip install --upgrade pip

###############################################################################
# Core numerical + vision stack
###############################################################################
"$MICROMAMBA_BIN" run -p "${ENV_PREFIX}" pip install \
  numpy==1.23.5 \
  scipy \
  opencv-python==4.7.0.72 \
  imageio \
  matplotlib

###############################################################################
# PyTorch (CUDA-enabled wheels)
###############################################################################
"$MICROMAMBA_BIN" run -p "${ENV_PREFIX}" pip install \
  torch==1.13.1+cu117 \
  torchvision==0.14.1+cu117 \
  torchaudio==0.13.1 \
  --extra-index-url https://download.pytorch.org/whl/cu117

###############################################################################
# HF + diffusion stack
###############################################################################
"$MICROMAMBA_BIN" run -p "${ENV_PREFIX}" pip install \
  huggingface_hub==0.19.4 \
  diffusers==0.24.0 \
  accelerate==0.21.0 \
  transformers==4.35.2 \
  sentence-transformers==2.2.2

"$MICROMAMBA_BIN" run -p "${ENV_PREFIX}" pip install \
  torchmetrics==0.7.3 \
  tensorboard

###############################################################################
# MotionLCM Python deps (inference-focused)
###############################################################################
"$MICROMAMBA_BIN" run -p "${ENV_PREFIX}" pip install \
  tqdm \
  pyyaml \
  einops \
  loguru \
  rich \
  gdown \
  omegaconf \
  hydra-core

###############################################################################
# Build-time sanity check (NO CUDA)
###############################################################################
"$MICROMAMBA_BIN" run -p "${ENV_PREFIX}" python - << 'EOF'
import torch
print("PyTorch:", torch.__version__)
print("CUDA built with:", torch.version.cuda)
EOF

###############################################################################
# Final message
###############################################################################
echo "============================================================"
echo "✅ MotionLCM environment ready at: ${ENV_PREFIX}"
echo "============================================================"
