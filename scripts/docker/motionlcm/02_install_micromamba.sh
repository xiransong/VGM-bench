#!/usr/bin/env bash
set -e

echo "============================================================"
echo "[INFO] Installing micromamba (Docker-safe)"
echo "============================================================"

###############################################################################
# Config (fixed paths, container-friendly)
###############################################################################
MAMBA_ROOT_PREFIX="/opt/micromamba"
BIN_DIR="$MAMBA_ROOT_PREFIX/bin"
MICROMAMBA_BIN="$BIN_DIR/micromamba"

###############################################################################
# Prepare directories
###############################################################################
mkdir -p "$BIN_DIR"

###############################################################################
# Download micromamba (official static build)
###############################################################################
echo "[INFO] Downloading micromamba..."

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

curl -L \
  https://micro.mamba.pm/api/micromamba/linux-64/latest \
  -o "$TMP_DIR/micromamba.tar.bz2"

###############################################################################
# Extract micromamba
###############################################################################
tar -xjf "$TMP_DIR/micromamba.tar.bz2" -C "$TMP_DIR"

if [ ! -f "$TMP_DIR/bin/micromamba" ]; then
  echo "[ERROR] micromamba binary not found after extraction!"
  exit 1
fi

mv "$TMP_DIR/bin/micromamba" "$MICROMAMBA_BIN"
chmod +x "$MICROMAMBA_BIN"

###############################################################################
# Sanity check
###############################################################################
echo "[INFO] Verifying micromamba installation..."
"$MICROMAMBA_BIN" --version

###############################################################################
# Final message
###############################################################################
echo "============================================================"
echo "✅ micromamba installed successfully"
echo "📍 Location: $MICROMAMBA_BIN"
echo "📦 Root prefix: $MAMBA_ROOT_PREFIX"
echo "============================================================"
