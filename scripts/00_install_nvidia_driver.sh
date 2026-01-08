#!/usr/bin/env bash
set -e

echo "=== Installing NVIDIA driver (non-interactive, headless) ==="

# -----------------------------------------------------------------------------
# 0. Force non-interactive mode (CRITICAL)
# -----------------------------------------------------------------------------
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a
export NEEDRESTART_SUSPEND=1

# -----------------------------------------------------------------------------
# 1. Suppress needrestart dialogs explicitly
# -----------------------------------------------------------------------------
sudo mkdir -p /etc/needrestart
sudo tee /etc/needrestart/needrestart.conf > /dev/null << 'EOF'
$nrconf{restart} = 'a';
$nrconf{kernelhints} = -1;
EOF

# -----------------------------------------------------------------------------
# 2. Update system (quietly)
# -----------------------------------------------------------------------------
sudo apt update -y

sudo apt install -y \
  build-essential \
  dkms \
  linux-headers-$(uname -r) \
  ubuntu-drivers-common

# -----------------------------------------------------------------------------
# 3. Detect and install recommended NVIDIA driver
# -----------------------------------------------------------------------------
echo "=== Detecting recommended NVIDIA driver ==="
ubuntu-drivers devices

echo "=== Installing NVIDIA driver via ubuntu-drivers ==="
sudo ubuntu-drivers autoinstall

# -----------------------------------------------------------------------------
# 4. Final message
# -----------------------------------------------------------------------------
echo "=== NVIDIA driver installation complete ==="
echo ">>> REBOOT REQUIRED <<<"
echo "After reboot, verify with: nvidia-smi"
