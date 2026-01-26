#!/usr/bin/env bash
set -e

echo "=== [01] System-level setup for VGM-bench ==="

# -----------------------------------------------------------------------------
# 0. Non-interactive mode (CRITICAL)
# -----------------------------------------------------------------------------
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a
export NEEDRESTART_SUSPEND=1

# -----------------------------------------------------------------------------
# 1. Base system update
# -----------------------------------------------------------------------------
sudo apt update -y
sudo apt upgrade -y

# -----------------------------------------------------------------------------
# 2. Core development & system tools
# -----------------------------------------------------------------------------
sudo apt install -y \
  build-essential \
  git \
  curl \
  wget \
  zip \
  unzip \
  tar \
  tmux \
  htop \
  tree \
  ca-certificates \
  software-properties-common \
  pkg-config \
  rsync

# -----------------------------------------------------------------------------
# 3. Networking & SSL sanity (often overlooked)
# -----------------------------------------------------------------------------
sudo apt install -y \
  openssh-client \
  gnupg \
  lsb-release

# -----------------------------------------------------------------------------
# 4. Python basics (NOT the main Python env)
# -----------------------------------------------------------------------------
# We install these ONLY for system scripts and tooling.
sudo apt install -y \
  python3 \
  python3-pip \
  python3-venv

# -----------------------------------------------------------------------------
# 5. Clean up
# -----------------------------------------------------------------------------
sudo apt autoremove -y
sudo apt autoclean -y

echo "=== [01] System setup complete ==="
