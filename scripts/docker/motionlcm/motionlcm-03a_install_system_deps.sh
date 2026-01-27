#!/usr/bin/env bash
set -e

echo "============================================================"
echo "[MotionLCM] Installing system dependencies (Docker-safe)"
echo "============================================================"

# -----------------------------------------------------------------------------
# Non-interactive mode
# -----------------------------------------------------------------------------
export DEBIAN_FRONTEND=noninteractive

# -----------------------------------------------------------------------------
# Install system-level dependencies required by MotionLCM
# -----------------------------------------------------------------------------
echo "[INFO] Installing system packages: git-lfs, ffmpeg..."

apt-get update && apt-get install -y \
    git-lfs \
    ffmpeg \
 && rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------------------------
# Initialize git-lfs (safe, optional)
# -----------------------------------------------------------------------------
echo "[INFO] Initializing git-lfs..."
git lfs install --skip-repo || true

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
echo "📦 git-lfs  : ready"
echo "🎞  ffmpeg  : ready"
echo "============================================================"
