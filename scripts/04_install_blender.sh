#!/usr/bin/env bash
set -euo pipefail

echo "============================================================"
echo "[INFO] Installing Blender (offline, reproducible)"
echo "============================================================"

###############################################################################
# Config
###############################################################################
BLENDER_VERSION="3.6.5"
BLENDER_NAME="blender-${BLENDER_VERSION}-linux-x64"
BLENDER_TARBALL="${BLENDER_NAME}.tar.xz"
BLENDER_URL="https://download.blender.org/release/Blender3.6/${BLENDER_TARBALL}"

SCRATCH_DIR="$HOME/scratch"
BLENDER_DIR="$SCRATCH_DIR/blender"
INSTALL_DIR="$BLENDER_DIR/${BLENDER_NAME}"
BLENDER_BIN="$INSTALL_DIR/blender"

###############################################################################
# Early exit if already installed
###############################################################################
if [ -x "$BLENDER_BIN" ]; then
  echo "[INFO] Blender already installed at:"
  echo "       $BLENDER_BIN"
  "$BLENDER_BIN" --version
  echo "============================================================"
  echo "✅ Blender already present — skipping install"
  echo "============================================================"
  exit 0
fi

###############################################################################
# Prepare directories
###############################################################################
echo "[INFO] Creating Blender directories..."
mkdir -p "$BLENDER_DIR"
cd "$BLENDER_DIR"

###############################################################################
# Download Blender
###############################################################################
echo "[INFO] Downloading Blender ${BLENDER_VERSION}..."
wget -q --show-progress "$BLENDER_URL"

###############################################################################
# Extract Blender
###############################################################################
echo "[INFO] Extracting Blender..."
tar -xf "$BLENDER_TARBALL"

###############################################################################
# Cleanup tarball
###############################################################################
rm "$BLENDER_TARBALL"

###############################################################################
# Add Blender to PATH (idempotent)
###############################################################################
echo "[INFO] Adding Blender to PATH..."

BLENDER_PATH_EXPORT="export PATH=${INSTALL_DIR}:\$PATH"

if ! grep -q "$BLENDER_PATH_EXPORT" "$HOME/.bashrc"; then
  echo "" >> "$HOME/.bashrc"
  echo "# >>> Blender (VGM-bench) >>>" >> "$HOME/.bashrc"
  echo "$BLENDER_PATH_EXPORT" >> "$HOME/.bashrc"
  echo "# <<< Blender (VGM-bench) <<<" >> "$HOME/.bashrc"
fi

###############################################################################
# Sanity check
###############################################################################
echo "[INFO] Verifying Blender installation..."
"$BLENDER_BIN" --version

###############################################################################
# Final message
###############################################################################
echo "============================================================"
echo "✅ Blender installed successfully"
echo "📍 Location: $BLENDER_BIN"
echo "➡️  Restart shell or run: source ~/.bashrc"
echo "============================================================"
