#!/usr/bin/env bash
set -euo pipefail

echo "============================================================"
echo "[INFO] Uploading SceneMI assets to GPU VM"
echo "============================================================"

# CHANGE THIS
VM_USER="ubuntu"
VM_HOST=$1

ARCHIVE="$HOME/scenemi_transfer/scenemi_assets.tar.gz"

if [ ! -f "$ARCHIVE" ]; then
  echo "[ERROR] Archive not found: $ARCHIVE"
  exit 1
fi

scp "$ARCHIVE" "$VM_USER@$VM_HOST:~/scratch/"

echo "============================================================"
echo "✅ Upload complete"
echo "============================================================"
