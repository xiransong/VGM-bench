#!/usr/bin/env bash
set -e

# ------------------------------------------------------------
# Contracted paths (DO NOT CHANGE lightly)
# ------------------------------------------------------------
CODE_ROOT="/opt/code/MotionLCM"
ASSET_ROOT="/opt/assets/MotionLCM"
DATASET_ROOT="/opt/datasets/HumanML3D"

echo "[MotionLCM ENTRYPOINT] Initializing container layout..."

# ------------------------------------------------------------
# Sanity checks (fail fast)
# ------------------------------------------------------------
if [ ! -d "$CODE_ROOT" ]; then
  echo "[ERROR] MotionLCM code not found at $CODE_ROOT"
  exit 1
fi

if [ ! -d "$ASSET_ROOT" ]; then
  echo "[ERROR] MotionLCM assets not found at $ASSET_ROOT"
  exit 1
fi

if [ ! -d "$DATASET_ROOT" ]; then
  echo "[ERROR] HumanML3D dataset not found at $DATASET_ROOT"
  exit 1
fi

# ------------------------------------------------------------
# Wire assets into MotionLCM repo
# ------------------------------------------------------------
for d in deps experiments_recons experiments_t2m experiments_control; do
  if [ -d "$ASSET_ROOT/$d" ]; then
    ln -sfn "$ASSET_ROOT/$d" "$CODE_ROOT/$d"
    echo "  linked $CODE_ROOT/$d -> $ASSET_ROOT/$d"
  fi
done

# ------------------------------------------------------------
# Wire HumanML3D dataset
# ------------------------------------------------------------
mkdir -p "$CODE_ROOT/datasets"
ln -sfn "$DATASET_ROOT" "$CODE_ROOT/datasets/humanml3d"
echo "  linked datasets/humanml3d -> $DATASET_ROOT"

echo "[MotionLCM ENTRYPOINT] Layout ready."

# ------------------------------------------------------------
# Execute user command
# ------------------------------------------------------------
exec "$@"
