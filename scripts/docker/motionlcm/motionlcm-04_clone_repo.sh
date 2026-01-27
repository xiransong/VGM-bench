#!/usr/bin/env bash
set -e

echo "============================================================"
echo "[MotionLCM] Cloning MotionLCM repository (Docker-safe)"
echo "============================================================"

###############################################################################
# Config (fixed paths)
###############################################################################
REPO_URL="https://github.com/xiransong/MotionLCM.git"
REPO_ROOT="/opt/repos"
REPO_NAME="MotionLCM"
REPO_DIR="${REPO_ROOT}/${REPO_NAME}"

PINNED_COMMIT="9ccba2678ad2af011fd6a5450a9605bf2638281d"

###############################################################################
# Prepare directory
###############################################################################
mkdir -p "${REPO_ROOT}"
cd "${REPO_ROOT}"

###############################################################################
# Clone repository
###############################################################################
echo "[INFO] Cloning MotionLCM from ${REPO_URL}..."
git clone "${REPO_URL}" "${REPO_NAME}"

cd "${REPO_DIR}"

###############################################################################
# Checkout pinned commit
###############################################################################
echo "[INFO] Checking out pinned commit ${PINNED_COMMIT}..."
git checkout "${PINNED_COMMIT}"

###############################################################################
# Final sanity check
###############################################################################
CURRENT_COMMIT="$(git rev-parse HEAD)"

if [ "${CURRENT_COMMIT}" != "${PINNED_COMMIT}" ]; then
  echo "[ERROR] Failed to pin MotionLCM to expected commit!"
  echo "Expected: ${PINNED_COMMIT}"
  echo "Got     : ${CURRENT_COMMIT}"
  exit 1
fi

###############################################################################
# Final status
###############################################################################
echo "============================================================"
echo "✅ MotionLCM repository ready (commit-pinned)"
echo "📍 Location : ${REPO_DIR}"
echo "🔒 Commit   : ${PINNED_COMMIT}"
echo "============================================================"

git --no-pager status
