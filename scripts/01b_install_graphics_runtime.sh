#!/usr/bin/env bash
set -e

echo "============================================================"
echo "[INFO] Installing system graphics runtime libraries"
echo "============================================================"

export DEBIAN_FRONTEND=noninteractive

sudo apt update -y

sudo apt install -y \
  libgl1 \
  libegl1 \
  libglvnd0 \
  libxrender1 \
  libxext6 \
  libsm6 \
  mesa-utils

echo "============================================================"
echo "✅ System graphics libraries installed"
echo "============================================================"
