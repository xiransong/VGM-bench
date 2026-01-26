#!/usr/bin/env bash
set -euo pipefail

echo "============================================================"
echo "[MotionLCM] (05a) Prepare assets download (deps + models)"
echo "============================================================"

###############################################################################
# Config
###############################################################################
REPO_DIR="$HOME/scratch/repos/MotionLCM"
LOG_DIR="$REPO_DIR/_logs"
STAMP_DIR="$REPO_DIR/_stamps"
TS="$(date -u +'%Y-%m-%dT%H-%M-%SZ')"
LOG_FILE="$LOG_DIR/prepare_assets_${TS}.log"

# MotionLCM prepare scripts (in recommended order)
PREPARE_SCRIPTS=(
  "prepare/download_glove.sh"
  "prepare/download_t2m_evaluators.sh"
  "prepare/prepare_t5.sh"
  "prepare/download_smpl_models.sh"
  "prepare/download_pretrained_models.sh"
)

# Expected folders/files after preparation (coarse checks; not exhaustive)
EXPECTED_PATHS=(
  "deps/glove"
  "deps/t2m"
  "deps/sentence-t5-large"
  "deps/smpl_models"
  "experiments_recons"
  "experiments_t2m"
  "experiments_control"
)

###############################################################################
# Preconditions
###############################################################################
if [ ! -d "$REPO_DIR/.git" ]; then
  echo "[ERROR] MotionLCM repo not found at: $REPO_DIR"
  echo "        Please run motionlcm-04_clone_repo.sh first."
  exit 1
fi

# Ensure git-lfs and ffmpeg exist (installed by motionlcm-03a_install_system_deps.sh)
command -v git-lfs >/dev/null 2>&1 || {
  echo "[ERROR] git-lfs not found. Run motionlcm-03a_install_system_deps.sh first."
  exit 1
}
command -v ffmpeg >/dev/null 2>&1 || {
  echo "[ERROR] ffmpeg not found. Run motionlcm-03a_install_system_deps.sh first."
  exit 1
}

###############################################################################
# Setup logging
###############################################################################
mkdir -p "$LOG_DIR" "$STAMP_DIR"

echo "[INFO] Repo dir : $REPO_DIR"
echo "[INFO] Log file : $LOG_FILE"
echo "[INFO] Start    : $TS"
echo ""

# Log everything (stdout + stderr) into a file, while still printing to terminal
exec > >(tee -a "$LOG_FILE") 2>&1

###############################################################################
# Print environment info (useful for debugging)
###############################################################################
echo "------------------------------------------------------------"
echo "[INFO] System diagnostics"
echo "------------------------------------------------------------"
uname -a || true
echo ""
echo "[INFO] git-lfs:"
git lfs version || true
echo ""
echo "[INFO] ffmpeg:"
ffmpeg -version | head -n 1 || true
echo ""
echo "[INFO] nvidia-smi (ok if absent on CPU VMs):"
nvidia-smi || true
echo ""

###############################################################################
# Run prepare scripts
###############################################################################
cd "$REPO_DIR"

echo "------------------------------------------------------------"
echo "[INFO] MotionLCM version snapshot"
echo "------------------------------------------------------------"
git --no-pager log -1 --decorate || true
echo ""

for s in "${PREPARE_SCRIPTS[@]}"; do
  if [ ! -f "$s" ]; then
    echo "[ERROR] Prepare script missing: $REPO_DIR/$s"
    exit 1
  fi
done

echo "------------------------------------------------------------"
echo "[INFO] Running prepare scripts"
echo "------------------------------------------------------------"

for s in "${PREPARE_SCRIPTS[@]}"; do
  STAMP="$STAMP_DIR/$(basename "$s").done"
  if [ -f "$STAMP" ]; then
    echo "[SKIP] $s (stamp exists: $STAMP)"
    continue
  fi

  echo ""
  echo "============================================================"
  echo "[RUN] $s"
  echo "============================================================"

  bash "$s"

  # Mark success
  touch "$STAMP"
  echo "[OK] Completed: $s"
done

###############################################################################
# Validate expected outputs
###############################################################################
echo ""
echo "------------------------------------------------------------"
echo "[INFO] Validating expected output paths"
echo "------------------------------------------------------------"

MISSING=0
for p in "${EXPECTED_PATHS[@]}"; do
  if [ -e "$REPO_DIR/$p" ]; then
    echo "[OK] $p"
  else
    echo "[MISS] $p"
    MISSING=1
  fi
done

if [ "$MISSING" -ne 0 ]; then
  echo ""
  echo "[ERROR] Some expected assets are missing."
  echo "Check log: $LOG_FILE"
  exit 1
fi

###############################################################################
# Summary
###############################################################################
echo ""
echo "============================================================"
echo "✅ MotionLCM assets preparation completed successfully"
echo "📍 Repo: $REPO_DIR"
echo "🧾 Log : $LOG_FILE"
echo "============================================================"
echo ""
echo "[NEXT] You can now proceed to:"
echo "  - motionlcm-05b_pack_assets.sh   (zip deps + checkpoints)"
echo "  - HumanML3D setup (upload/unzip into datasets/humanml3d)"
echo "  - Run demo: python demo.py --cfg configs/motionlcm_control_s.yaml"
