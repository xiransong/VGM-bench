#!/usr/bin/env bash
set -euo pipefail

echo "============================================================"
echo "[INFO] Installing SceneMI training dependencies (curated)"
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

###############################################################################
# Activate environment
###############################################################################
echo "[INFO] Activating environment '${ENV_NAME}'..."
micromamba activate "${ENV_NAME}"

###############################################################################
# Safety check: Torch should already be present and CUDA-enabled
###############################################################################
echo "[INFO] Verifying existing PyTorch installation..."
python - << 'EOF'
import torch
print("Torch:", torch.__version__)
print("CUDA available:", torch.cuda.is_available())
if not torch.cuda.is_available():
    raise RuntimeError("CUDA not available — aborting dependency install")
EOF

###############################################################################
# Core training dependencies (Tier-1)
###############################################################################
echo "[INFO] Installing core SceneMI training dependencies..."

pip install \
  blobfile \
  tqdm \
  tensorboard \
  pyyaml \
  pillow \
  einops \
  vit-pytorch \
  smplx==0.1.28 \
  wandb==0.16.6

###############################################################################
# CLIP (import-only requirement)
# NOTE:
# - SceneMI does NOT use text conditioning in training
# - CLIP is imported at module scope; must be importable
###############################################################################
echo "[INFO] Installing CLIP (import-only dependency)..."

pip install \
  git+https://github.com/openai/CLIP.git

###############################################################################
# Optional but safe utilities (Tier-2)
# (kept minimal; comment out if you want ultra-lean installs)
###############################################################################
echo "[INFO] Installing optional utilities (safe)..."

pip install \
  matplotlib

###############################################################################
# Sanity checks
###############################################################################
echo "[INFO] Running dependency sanity checks..."

python - << 'EOF'
import importlib

required = [
    "blobfile",
    "tqdm",
    "tensorboard",
    "yaml",
    "einops",
    "smplx",
    "clip",
]

for m in required:
    importlib.import_module(m)
    print(f"[OK] import {m}")

# Model-critical imports
from vit_pytorch import ViT
print("[OK] vit_pytorch.ViT")

print("SceneMI dependency sanity check PASSED")
EOF

###############################################################################
# Final message
###############################################################################
echo "============================================================"
echo "✅ SceneMI dependencies installed successfully"
echo "📌 Scope: Training-only (motion in-betweening)"
echo "➡️  Next step: preprocess dataset"
echo "============================================================"
