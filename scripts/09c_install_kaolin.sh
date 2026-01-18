#!/usr/bin/env bash
set -euo pipefail

echo "============================================================"
echo "[KAOLIN] Building Kaolin with system CUDA + conda PyTorch"
echo "============================================================"

# IMPORTANT:
# We intentionally use system CUDA (nvcc + headers) with conda PyTorch.
# Do NOT replace this with conda cudatoolkit-dev.

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
# Activate environment
###############################################################################
ENV_NAME="scenemi"
echo "[INFO] Activating environment '${ENV_NAME}'..."
micromamba activate "${ENV_NAME}"

###############################################################################
# Verify PyTorch CUDA runtime
###############################################################################
python - << 'EOF'
import torch
print("Torch:", torch.__version__)
print("Torch CUDA:", torch.version.cuda)
assert torch.cuda.is_available()
EOF

###############################################################################
# Bind system CUDA
###############################################################################
export CUDA_HOME="/usr/local/cuda-12.1"
export PATH="${CUDA_HOME}/bin:${PATH:-}"
export LD_LIBRARY_PATH="${CUDA_HOME}/lib64:${LD_LIBRARY_PATH:-}"

echo "[INFO] CUDA_HOME set to ${CUDA_HOME}"

python - << 'EOF'
import os
assert os.path.exists(os.path.join(os.environ["CUDA_HOME"], "include", "cusparse.h"))
assert os.path.exists(os.path.join(os.environ["CUDA_HOME"], "bin", "nvcc"))
print("✔ CUDA headers and nvcc detected")
EOF

###############################################################################
# Force CUDA-compatible compiler for nvcc
###############################################################################
export CC=/usr/bin/gcc-11
export CXX=/usr/bin/g++-11

echo "[INFO] Using host compiler for nvcc:"
$CC --version

###############################################################################
# Clone Kaolin
###############################################################################
KAOLIN_DIR="$HOME/scratch/repos/kaolin"

if [ ! -d "$KAOLIN_DIR" ]; then
  git clone --recursive https://github.com/NVIDIAGameWorks/kaolin.git "$KAOLIN_DIR"
fi

cd "$KAOLIN_DIR"
git fetch origin
git checkout v0.18.0
git submodule update --init --recursive

###############################################################################
# Python build requirements (exact versions Kaolin expects)
###############################################################################
pip install --upgrade pip
pip install \
  "setuptools<75.9" \
  wheel \
  cython==0.29.37

pip install \
  -r tools/build_requirements.txt \
  -r tools/requirements.txt

###############################################################################
# Clean + build
###############################################################################
echo "[INFO] Cleaning previous builds..."
python setup.py clean || true
rm -rf build

export MAX_JOBS=4
export TORCH_CUDA_ARCH_LIST="8.6"

echo "[INFO] Building Kaolin (this will take a while)..."
python setup.py develop

###############################################################################
# Verification
###############################################################################
python - << 'EOF'
import kaolin
print("Kaolin version:", kaolin.__version__)
EOF

echo "[SUCCESS] Kaolin built successfully"
