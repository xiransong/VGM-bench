#!/usr/bin/env bash
set -euo pipefail

echo "============================================================"
echo "[MotionLCM] (05b) Pack prepared assets into MotionLCM_assets.zip"
echo "============================================================"

###############################################################################
# Config
###############################################################################
REPO_DIR="$HOME/scratch/repos/MotionLCM"
CACHE_DIR="$HOME/scratch/assets_cache"
ASSET_ZIP="$CACHE_DIR/MotionLCM_assets.zip"
ASSET_SHA="$ASSET_ZIP.sha256"

INCLUDE_PATHS=(
  "deps"
  "experiments_recons"
  "experiments_t2m"
  "experiments_control"
)

EXCLUDE_PATTERNS=(
  ".git"
  "datasets"
  "_logs"
  "_stamps"
  "__pycache__"
)

###############################################################################
# Preconditions
###############################################################################
if [ ! -d "$REPO_DIR" ]; then
  echo "[ERROR] MotionLCM repo not found at $REPO_DIR"
  exit 1
fi

mkdir -p "$CACHE_DIR"

###############################################################################
# Validate include paths
###############################################################################
echo "[INFO] Validating asset directories..."

for p in "${INCLUDE_PATHS[@]}"; do
  if [ ! -d "$REPO_DIR/$p" ]; then
    echo "[ERROR] Required path missing: $REPO_DIR/$p"
    exit 1
  fi
  echo "[OK] $p"
done

###############################################################################
# Build exclude args for zip
###############################################################################
ZIP_EXCLUDES=()
for e in "${EXCLUDE_PATTERNS[@]}"; do
  ZIP_EXCLUDES+=( "-x" "*/$e/*" )
done

###############################################################################
# Create zip
###############################################################################
echo "------------------------------------------------------------"
echo "[INFO] Creating asset archive:"
echo "  $ASSET_ZIP"
echo "------------------------------------------------------------"

cd "$REPO_DIR"

rm -f "$ASSET_ZIP" "$ASSET_SHA"

zip -r "$ASSET_ZIP" \
  "${INCLUDE_PATHS[@]}" \
  "${ZIP_EXCLUDES[@]}"

###############################################################################
# Generate checksum
###############################################################################
echo "------------------------------------------------------------"
echo "[INFO] Generating checksum"
echo "------------------------------------------------------------"

sha256sum "$ASSET_ZIP" | tee "$ASSET_SHA"

###############################################################################
# Summary
###############################################################################
echo ""
echo "============================================================"
echo "✅ MotionLCM assets packaged successfully"
echo "📦 Archive : $ASSET_ZIP"
echo "🔐 SHA256  : $(cut -d ' ' -f1 "$ASSET_SHA")"
echo "============================================================"
echo ""
echo "[NEXT]"
echo "  - Copy $ASSET_ZIP to your Mac for safekeeping"
echo "  - Later: motionlcm-05c_unpack_assets.sh on new VMs"
