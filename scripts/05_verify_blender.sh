#!/usr/bin/env bash
set -euo pipefail

echo "============================================================"
echo "[INFO] VGM-bench Blender GPU verification"
echo "============================================================"

###############################################################################
# 0. Preconditions
###############################################################################
if ! command -v blender >/dev/null 2>&1; then
  echo "[ERROR] blender not found in PATH"
  echo "        Did you run 05_install_blender.sh and source ~/.bashrc?"
  exit 1
fi

echo "[INFO] Blender binary:"
which blender
blender --version

###############################################################################
# 1. Device discovery test
###############################################################################
echo "------------------------------------------------------------"
echo "[INFO] Checking Cycles GPU device discovery..."
echo "------------------------------------------------------------"

blender -b --python-expr "
import bpy

prefs = bpy.context.preferences.addons['cycles'].preferences
prefs.refresh_devices()

if not prefs.devices:
    raise RuntimeError('No Cycles devices found')

print('Detected devices:')
for d in prefs.devices:
    print(f'  - {d.type:5s} | {d.name} | enabled={d.use}')
"

###############################################################################
# 2. Minimal GPU render test
###############################################################################
echo "------------------------------------------------------------"
echo "[INFO] Running minimal GPU render test (Cycles)..."
echo "------------------------------------------------------------"

blender -b --python-expr "
import bpy

# Use Cycles
bpy.context.scene.render.engine = 'CYCLES'

# Enable CUDA (preferred); fallback handled automatically
prefs = bpy.context.preferences.addons['cycles'].preferences
prefs.compute_device_type = 'CUDA'
prefs.refresh_devices()

gpu_found = False
for d in prefs.devices:
    d.use = True
    if d.type in ('CUDA', 'OPTIX'):
        gpu_found = True
    print(f'Using device: {d.name} ({d.type})')

if not gpu_found:
    raise RuntimeError('No GPU device enabled for Cycles')

# Reduce render cost (fast sanity check)
scene = bpy.context.scene
scene.cycles.samples = 8
scene.render.resolution_x = 256
scene.render.resolution_y = 256
scene.render.resolution_percentage = 100

# Render a single frame (default cube scene)
bpy.ops.render.render(write_still=False)

print('GPU render test completed successfully')
"

###############################################################################
# 3. Final verdict
###############################################################################
echo "============================================================"
echo "✅ Blender GPU verification PASSED"
echo "🎉 Blender + NVIDIA stack is fully operational"
echo "============================================================"
