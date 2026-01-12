#!/usr/bin/env bash
set -euo pipefail

echo "============================================================"
echo "[INFO] Installing SceneMI repository (xiran-dev branch)"
echo "============================================================"

###############################################################################
# Config
###############################################################################
SCENEMI_REPO_URL="https://github.com/xiransong/SceneMI"
SCENEMI_DIR="$HOME/scratch/repos/SceneMI"

# Branch to use for active development
SCENEMI_BRANCH="xiran-dev"

# Optional hard pin for full reproducibility (recommended for paper snapshots)
SCENEMI_COMMIT="db8cd7bb115c00097f535fd50142f91c78448901"

###############################################################################
# Preconditions
###############################################################################
if ! command -v git >/dev/null 2>&1; then
  echo "[ERROR] git not found"
  exit 1
fi

###############################################################################
# Clone repository if needed
###############################################################################
if [ -d "$SCENEMI_DIR/.git" ]; then
  echo "[INFO] SceneMI repo already exists at:"
  echo "       $SCENEMI_DIR"
else
  echo "[INFO] Cloning SceneMI from fork..."
  mkdir -p "$(dirname "$SCENEMI_DIR")"
  git clone "$SCENEMI_REPO_URL" "$SCENEMI_DIR"
fi

###############################################################################
# Enter repo
###############################################################################
cd "$SCENEMI_DIR"

###############################################################################
# Fetch updates
###############################################################################
echo "[INFO] Fetching latest updates..."
git fetch --all

###############################################################################
# Checkout branch
###############################################################################
echo "[INFO] Checking out branch: $SCENEMI_BRANCH"
git checkout "$SCENEMI_BRANCH"

###############################################################################
# Optional: checkout specific commit
###############################################################################
if [ -n "$SCENEMI_COMMIT" ]; then
  echo "[INFO] Hard-pinning SceneMI to commit:"
  echo "       $SCENEMI_COMMIT"
  git checkout "$SCENEMI_COMMIT"
fi

###############################################################################
# Log exact repo state (critical for research reproducibility)
###############################################################################
echo "------------------------------------------------------------"
echo "[INFO] SceneMI repository state:"
echo "Branch:"
git branch --show-current
echo "Commit:"
git rev-parse HEAD
echo "------------------------------------------------------------"

###############################################################################
# Final message
###############################################################################
echo "============================================================"
echo "✅ SceneMI repository is ready"
echo "📍 Location: $SCENEMI_DIR"
echo "📌 Active branch : $SCENEMI_BRANCH"
echo "📌 Pinned commit : ${SCENEMI_COMMIT:-<none>}"
echo "➡️  Next step: install SceneMI dependencies"
echo "============================================================"
