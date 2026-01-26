#!/usr/bin/env bash
set -euo pipefail

echo "============================================================"
echo "[INFO] Creating and populating vgm-bench environment"
echo "============================================================"

# --- micromamba bootstrap ---
MAMBA_ROOT_PREFIX="$HOME/scratch/micromamba"
MICROMAMBA_BIN="$MAMBA_ROOT_PREFIX/bin/micromamba"

if [ ! -x "$MICROMAMBA_BIN" ]; then
  echo "[ERROR] micromamba not found at $MICROMAMBA_BIN"
  exit 1
fi

eval "$("$MICROMAMBA_BIN" shell hook --shell bash --root-prefix "$MAMBA_ROOT_PREFIX")"
# ----------------------------

###############################################################################
# Config
###############################################################################
ENV_NAME="vgm-bench"
PYTHON_VERSION="3.11"

# Binary / scientific stack (micromamba)
MAMBA_PACKAGES=(
  python=${PYTHON_VERSION}
  numpy
  scipy
  matplotlib
  pillow
  pyyaml
  tqdm
  opencv
  imageio
)

# Pure Python / project-level deps (pip)
PIP_PACKAGES=(
  loguru
  rich
)

###############################################################################
# Preconditions
###############################################################################
if ! command -v micromamba >/dev/null 2>&1; then
  echo "[ERROR] micromamba not found in PATH"
  echo "        Did you run 02_install_micromamba.sh and source ~/.bashrc?"
  exit 1
fi

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
eval "$(micromamba shell hook --shell bash)"
micromamba activate "${ENV_NAME}"

###############################################################################
# Install pip packages
###############################################################################
echo "[INFO] Installing pip packages..."

pip install --upgrade pip

for pkg in "${PIP_PACKAGES[@]}"; do
  pip install "${pkg}"
done

###############################################################################
# Sanity check
###############################################################################
echo "[INFO] Environment sanity check:"
python - << 'EOF'
import sys
import numpy
import cv2
print("Python:", sys.version)
print("NumPy:", numpy.__version__)
print("OpenCV:", cv2.__version__)
EOF

###############################################################################
# Final message
###############################################################################
echo "============================================================"
echo "✅ Environment '${ENV_NAME}' is ready"
echo "➡️  Activate with: micromamba activate ${ENV_NAME}"
echo "============================================================"
