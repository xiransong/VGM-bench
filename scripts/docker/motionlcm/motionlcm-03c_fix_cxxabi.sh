#!/usr/bin/env bash
set -e

echo "============================================================"
echo "[MotionLCM] Installing C++ runtime (Docker-safe)"
echo "============================================================"

###############################################################################
# Config
###############################################################################
MAMBA_ROOT_PREFIX="/opt/micromamba"
ENV_PREFIX="${MAMBA_ROOT_PREFIX}/envs/motionlcm"
MICROMAMBA_BIN="${MAMBA_ROOT_PREFIX}/bin/micromamba"

if [ ! -x "$MICROMAMBA_BIN" ]; then
  echo "[ERROR] micromamba not found at $MICROMAMBA_BIN"
  exit 1
fi

###############################################################################
# Install libstdcxx-ng into MotionLCM env
###############################################################################
echo "[INFO] Installing libstdcxx-ng into MotionLCM env..."

"$MICROMAMBA_BIN" install -y \
  -p "${ENV_PREFIX}" \
  -c conda-forge \
  libstdcxx-ng

###############################################################################
# Sanity check
###############################################################################
echo "[INFO] Checking libstdc++ presence..."

ls "${ENV_PREFIX}/lib/libstdc++.so"* || {
  echo "[ERROR] libstdc++ not found in env!"
  exit 1
}

###############################################################################
# Final message
###############################################################################
echo "============================================================"
echo "✅ C++ runtime installed in MotionLCM environment"
echo "============================================================"
