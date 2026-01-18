#!/usr/bin/env bash
set -euo pipefail

echo "============================================================"
echo "[PYTORCH3D] Building PyTorch3D with system CUDA + conda PyTorch"
echo "============================================================"

###############################################################################
# micromamba bootstrap
###############################################################################
MAMBA_ROOT_PREFIX="$HOME/scratch/micromamba"
MICROMAMBA_BIN="$MAMBA_ROOT_PREFIX/bin/micromamba"

eval "$("$MICROMAMBA_BIN" shell hook --shell bash --root-prefix "$MAMBA_ROOT_PREFIX")"
micromamba activate scenemi

###############################################################################
# Verify PyTorch
###############################################################################
python - << 'EOF'
import torch
print("Torch:", torch.__version__)
print("Torch CUDA:", torch.version.cuda)
assert torch.cuda.is_available()
EOF

###############################################################################
# Clean old install
###############################################################################
pip uninstall -y pytorch3d || true
cd ~/scratch/repos
rm -rf pytorch3d
git clone https://github.com/facebookresearch/pytorch3d.git
cd pytorch3d

###############################################################################
# CRITICAL: clean env flags (prevents nvcc '' bug)
###############################################################################
unset CFLAGS
unset CXXFLAGS
unset CPPFLAGS
unset NVCC_FLAGS
unset TORCH_NVCC_FLAGS
unset CUDA_PATH
unset CUDACXX

###############################################################################
# Bind SYSTEM CUDA (headers + nvcc)
###############################################################################
export CUDA_HOME="/usr/local/cuda-12.1"
export PATH="$CUDA_HOME/bin:${PATH:-}"
export LD_LIBRARY_PATH="$CUDA_HOME/lib64:${LD_LIBRARY_PATH:-}"

export CPATH="$CUDA_HOME/include"
export C_INCLUDE_PATH="$CUDA_HOME/include"
export CPLUS_INCLUDE_PATH="$CUDA_HOME/include"
export CUB_HOME="$CUDA_HOME/include"

###############################################################################
# Compiler + arch
###############################################################################
export CC=/usr/bin/gcc-11
export CXX=/usr/bin/g++-11
export TORCH_CUDA_ARCH_LIST="8.6"
export MAX_JOBS=4

###############################################################################
# Sanity check CUDA headers
###############################################################################
test -f "$CUDA_HOME/include/cusparse.h" || {
  echo "[ERROR] cusparse.h not found in $CUDA_HOME/include"
  exit 1
}

nvcc --version

###############################################################################
# Build
###############################################################################
python setup.py clean --all || true
rm -rf build
python setup.py develop

###############################################################################
# Verification
###############################################################################
python - << 'EOF'
import torch
from pytorch3d.ops import knn_points

x = torch.randn(1, 8, 3, device="cuda")
y = torch.randn(1, 16, 3, device="cuda")

d, idx, _ = knn_points(x, y, K=3)
print("✔ PyTorch3D CUDA OK:", d.is_cuda)
EOF

echo "============================================================"
echo "✅ PyTorch3D installed with CUDA support"
echo "============================================================"
