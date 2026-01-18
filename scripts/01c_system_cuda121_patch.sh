#!/usr/bin/env bash
set -euo pipefail

echo "============================================================"
echo "[SYSTEM] Installing CUDA 12.1 toolkit (headers + nvcc only)"
echo "============================================================"

###############################################################################
# Install CUDA-compatible compiler (gcc-11)
###############################################################################
echo "[INFO] Installing CUDA-compatible GCC (gcc-11)..."
sudo apt install -y gcc-11 g++-11

echo "[INFO] GCC versions:"
gcc-11 --version
g++-11 --version

# -----------------------------
# Detect Ubuntu version
# -----------------------------
UBUNTU_VER=$(lsb_release -rs)
if [[ "$UBUNTU_VER" == "22.04" ]]; then
  CUDA_REPO="ubuntu2204"
elif [[ "$UBUNTU_VER" == "20.04" ]]; then
  CUDA_REPO="ubuntu2004"
else
  echo "[ERROR] Unsupported Ubuntu version: $UBUNTU_VER"
  exit 1
fi

echo "[INFO] Ubuntu version: $UBUNTU_VER ($CUDA_REPO)"

# -----------------------------
# Add NVIDIA CUDA repository
# -----------------------------
echo "[INFO] Adding NVIDIA CUDA APT repository..."

PIN_FILE="cuda-${CUDA_REPO}.pin"
if [ ! -f "/etc/apt/preferences.d/cuda-repository-pin-600" ]; then
  wget -q https://developer.download.nvidia.com/compute/cuda/repos/${CUDA_REPO}/x86_64/${PIN_FILE}
  sudo mv ${PIN_FILE} /etc/apt/preferences.d/cuda-repository-pin-600
fi

sudo apt-key adv --fetch-keys \
  https://developer.download.nvidia.com/compute/cuda/repos/${CUDA_REPO}/x86_64/3bf863cc.pub

sudo add-apt-repository -y \
  "deb https://developer.download.nvidia.com/compute/cuda/repos/${CUDA_REPO}/x86_64/ /"

sudo apt update

# -----------------------------
# Install CUDA toolkit only
# -----------------------------
echo "[INFO] Installing cuda-toolkit-12-1..."
sudo apt install -y cuda-toolkit-12-1

# -----------------------------
# Verification
# -----------------------------
CUDA_HOME="/usr/local/cuda-12.1"

echo "[INFO] Verifying CUDA installation..."
test -x "${CUDA_HOME}/bin/nvcc" || { echo "[ERROR] nvcc missing"; exit 1; }
test -f "${CUDA_HOME}/include/cusparse.h" || { echo "[ERROR] cusparse.h missing"; exit 1; }

echo "[SUCCESS] CUDA 12.1 toolkit installed at ${CUDA_HOME}"
"${CUDA_HOME}/bin/nvcc" --version
