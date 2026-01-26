#!/usr/bin/env bash
set -euo pipefail

echo "============================================================"
echo "[INFO] Fixing C++ ABI (libstdc++) for MotionLCM"
echo "============================================================"

# Ensure env is active
if [ -z "${CONDA_PREFIX:-}" ]; then
  echo "[ERROR] motionlcm environment not activated"
  exit 1
fi

# Install modern C++ runtime
micromamba install -y -c conda-forge libstdcxx-ng

# Add activate hook
ACTIVATE_DIR="$CONDA_PREFIX/etc/conda/activate.d"
mkdir -p "$ACTIVATE_DIR"

cat > "$ACTIVATE_DIR/zz_libstdcxx_fix.sh" <<'EOF'
#!/usr/bin/env bash
export LD_LIBRARY_PATH="$CONDA_PREFIX/lib:${LD_LIBRARY_PATH:-}"
EOF

chmod +x "$ACTIVATE_DIR/zz_libstdcxx_fix.sh"

echo "============================================================"
echo "✅ C++ ABI fix installed (auto-applied on env activation)"
echo "============================================================"
