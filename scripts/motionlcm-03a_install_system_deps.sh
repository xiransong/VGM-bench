#!/usr/bin/env bash
set -euo pipefail

echo "============================================================"
echo "[MotionLCM] Installing MotionLCM-specific system dependencies"
echo "============================================================"

# -----------------------------------------------------------------------------
# Non-interactive mode (safety for cloud / CI)
# -----------------------------------------------------------------------------
export DEBIAN_FRONTEND=noninteractive

# -----------------------------------------------------------------------------
# Update package index
# -----------------------------------------------------------------------------
echo "[INFO] Updating APT package index..."
sudo apt update -y

# -----------------------------------------------------------------------------
# Install system-level dependencies required by MotionLCM
# -----------------------------------------------------------------------------
echo "[INFO] Installing system packages: git-lfs, ffmpeg..."

sudo apt install -y \
  git-lfs \
  ffmpeg

# -----------------------------------------------------------------------------
# Initialize git-lfs (idempotent)
# -----------------------------------------------------------------------------
echo "[INFO] Initializing git-lfs..."
git lfs install --skip-repo

# -----------------------------------------------------------------------------
# Sanity checks
# -----------------------------------------------------------------------------
echo "[INFO] Verifying installations..."

command -v git-lfs >/dev/null 2>&1 || {
  echo "[ERROR] git-lfs not found after installation!"
  exit 1
}

command -v ffmpeg >/dev/null 2>&1 || {
  echo "[ERROR] ffmpeg not found after installation!"
  exit 1
}

git lfs version
ffmpeg -version | head -n 1

# -----------------------------------------------------------------------------
# Final message
# -----------------------------------------------------------------------------
echo "============================================================"
echo "✅ MotionLCM system dependencies installed successfully"
echo "📦 git-lfs  : ready (for pretrained checkpoints)"
echo "🎞  ffmpeg  : ready (for motion visualization)"
echo "============================================================"
