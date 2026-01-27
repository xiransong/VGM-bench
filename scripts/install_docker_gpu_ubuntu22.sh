#!/usr/bin/env bash
set -e

echo "============================================================"
echo "[SETUP] Docker + NVIDIA Container Toolkit (Ubuntu 22.04)"
echo "============================================================"

###############################################################################
# 0. Sanity checks
###############################################################################
if ! lsb_release -a 2>/dev/null | grep -q "Ubuntu 22.04"; then
  echo "[ERROR] This script is intended for Ubuntu 22.04 only."
  lsb_release -a || true
  exit 1
fi

###############################################################################
# 1. Update system
###############################################################################
sudo apt update
sudo apt install -y \
  ca-certificates \
  curl \
  gnupg \
  lsb-release

###############################################################################
# 2. Install Docker Engine
###############################################################################
echo "[INFO] Installing Docker..."

# Remove old versions if any
sudo apt remove -y docker docker-engine docker.io containerd runc || true

# Add Docker GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add Docker repo
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update

sudo apt install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

###############################################################################
# 3. Enable Docker without sudo (recommended)
###############################################################################
sudo usermod -aG docker $USER

###############################################################################
# 4. Install NVIDIA Container Toolkit
###############################################################################
echo "[INFO] Installing NVIDIA Container Toolkit..."

curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey \
  | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit.gpg

curl -fsSL https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list \
  | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit.gpg] https://#g' \
  | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo apt update
sudo apt install -y nvidia-container-toolkit

###############################################################################
# 5. Configure Docker to use NVIDIA runtime
###############################################################################
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

###############################################################################
# 6. Final instructions
###############################################################################
echo "============================================================"
echo "✅ Docker + NVIDIA Container Toolkit installed"
echo
echo "⚠️ IMPORTANT:"
echo "1. Log out and log back in (or reboot) so docker group takes effect"
echo "2. Verify GPU with:"
echo "     docker run --rm --gpus all nvidia/cuda:12.2.0-base-ubuntu22.04 nvidia-smi"
echo "============================================================"
