#!/usr/bin/env bash
set -euo pipefail

echo "============================================================"
echo "[MotionLCM] Cloning MotionLCM repository (oracle setup)"
echo "============================================================"

###############################################################################
# Config
###############################################################################
REPO_URL="https://github.com/xiransong/MotionLCM.git"
REPO_ROOT="$HOME/scratch/repos"
REPO_NAME="MotionLCM"
REPO_DIR="$REPO_ROOT/$REPO_NAME"

BRANCH_NAME="xiran-dev"
PINNED_COMMIT="9ccba2678ad2af011fd6a5450a9605bf2638281d"

###############################################################################
# Prepare directory
###############################################################################
mkdir -p "$REPO_ROOT"

###############################################################################
# Clone or fetch
###############################################################################
if [ -d "$REPO_DIR/.git" ]; then
  echo "[INFO] Repository already exists at $REPO_DIR"
  cd "$REPO_DIR"
  git fetch origin
else
  echo "[INFO] Cloning MotionLCM from $REPO_URL"
  git clone "$REPO_URL" "$REPO_DIR"
  cd "$REPO_DIR"
fi

###############################################################################
# Checkout branch and pinned commit
###############################################################################
echo "[INFO] Checking out branch '$BRANCH_NAME'..."
git checkout "$BRANCH_NAME"

echo "[INFO] Resetting to pinned commit $PINNED_COMMIT"
git reset --hard "$PINNED_COMMIT"

###############################################################################
# Final sanity check
###############################################################################
CURRENT_COMMIT="$(git rev-parse HEAD)"

if [ "$CURRENT_COMMIT" != "$PINNED_COMMIT" ]; then
  echo "[ERROR] Failed to pin MotionLCM to expected commit!"
  echo "Expected: $PINNED_COMMIT"
  echo "Got     : $CURRENT_COMMIT"
  exit 1
fi

###############################################################################
# Final status
###############################################################################
echo "============================================================"
echo "✅ MotionLCM repository ready (commit-pinned)"
echo "📍 Location : $REPO_DIR"
echo "🌱 Branch   : $BRANCH_NAME"
echo "🔒 Commit   : $PINNED_COMMIT"
echo "============================================================"

git --no-pager status
