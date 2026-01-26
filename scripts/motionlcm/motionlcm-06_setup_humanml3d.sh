#!/usr/bin/env bash
set -euo pipefail

echo "============================================================"
echo "[MotionLCM] (06) Setup HumanML3D dataset"
echo "============================================================"

###############################################################################
# Config
###############################################################################
REPO_DIR="$HOME/scratch/repos/MotionLCM"
CACHE_DIR="$HOME/scratch/assets_cache"

HML_ZIP="$CACHE_DIR/HumanML3D.zip"
DATASET_ROOT="$REPO_DIR/datasets"
TARGET_DIR="$DATASET_ROOT/humanml3d"

# Set to 1 ONLY if you want to overwrite existing HumanML3D
FORCE_OVERWRITE=0

###############################################################################
# Preconditions
###############################################################################
if [ ! -d "$REPO_DIR/.git" ]; then
  echo "[ERROR] MotionLCM repo not found at: $REPO_DIR"
  exit 1
fi

if [ ! -f "$HML_ZIP" ]; then
  echo "[ERROR] HumanML3D.zip not found at:"
  echo "        $HML_ZIP"
  echo ""
  echo "Please upload it from your Mac, e.g.:"
  echo "  scp HumanML3D.zip ubuntu@<VM_IP>:$CACHE_DIR/"
  exit 1
fi

command -v unzip >/dev/null 2>&1 || {
  echo "[ERROR] unzip not found. Did you install it in 01_setup_system.sh?"
  exit 1
}

mkdir -p "$DATASET_ROOT"

###############################################################################
# Existing dataset check
###############################################################################
if [ -d "$TARGET_DIR" ]; then
  echo "[WARN] Existing HumanML3D directory detected:"
  echo "       $TARGET_DIR"

  if [ "$FORCE_OVERWRITE" -ne 1 ]; then
    echo ""
    echo "[ERROR] Refusing to overwrite existing dataset."
    echo "Options:"
    echo "  - Remove $TARGET_DIR manually, OR"
    echo "  - Re-run with FORCE_OVERWRITE=1 in this script"
    exit 1
  else
    echo "[INFO] FORCE_OVERWRITE enabled — removing existing dataset..."
    rm -rf "$TARGET_DIR"
  fi
fi

###############################################################################
# Unzip HumanML3D
###############################################################################
echo "------------------------------------------------------------"
echo "[INFO] Unzipping HumanML3D dataset"
echo "------------------------------------------------------------"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

unzip -q "$HML_ZIP" -d "$TMP_DIR"

###############################################################################
# Detect inner directory structure
###############################################################################
echo "[INFO] Detecting HumanML3D root directory..."

# Common cases:
#   HumanML3D/
#   HumanML3D/HumanML3D/
#   humanml3d/
CANDIDATES=(
  "$TMP_DIR/HumanML3D"
  "$TMP_DIR/HumanML3D/HumanML3D"
  "$TMP_DIR/humanml3d"
)

SRC_DIR=""
for c in "${CANDIDATES[@]}"; do
  if [ -d "$c" ]; then
    SRC_DIR="$c"
    break
  fi
done

if [ -z "$SRC_DIR" ]; then
  echo "[ERROR] Could not locate HumanML3D directory inside zip."
  echo "Please inspect the zip structure manually."
  exit 1
fi

echo "[INFO] Found dataset at: $SRC_DIR"

###############################################################################
# Move into MotionLCM structure
###############################################################################
echo "------------------------------------------------------------"
echo "[INFO] Installing HumanML3D into MotionLCM"
echo "------------------------------------------------------------"

mkdir -p "$TARGET_DIR"
rsync -a "$SRC_DIR"/ "$TARGET_DIR"/

###############################################################################
# Sanity checks (minimal but meaningful)
###############################################################################
echo "------------------------------------------------------------"
echo "[INFO] Verifying HumanML3D dataset structure"
echo "------------------------------------------------------------"

REQUIRED_SUBDIRS=(
  "new_joint_vecs"
  "new_joints"
  "texts"
  "Mean.npy"
  "Std.npy"
)

MISSING=0
for item in "${REQUIRED_SUBDIRS[@]}"; do
  if [ -e "$TARGET_DIR/$item" ]; then
    echo "[OK] $item"
  else
    echo "[MISS] $item"
    MISSING=1
  fi
done

if [ "$MISSING" -ne 0 ]; then
  echo ""
  echo "[ERROR] HumanML3D dataset appears incomplete."
  echo "Please verify the contents of $HML_ZIP."
  exit 1
fi

###############################################################################
# Summary
###############################################################################
echo ""
echo "============================================================"
echo "✅ HumanML3D dataset installed successfully"
echo "📍 Location: $TARGET_DIR"
echo "============================================================"
echo ""
echo "[NEXT]"
echo "  Activate env : micromamba activate motionlcm"
echo "  Run demo     : python demo.py --cfg configs/motionlcm_control_s.yaml"
