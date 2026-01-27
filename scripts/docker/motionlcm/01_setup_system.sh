#!/usr/bin/env bash
set -e

echo "=== [01] System-level setup (Docker-safe) ==="

# -----------------------------------------------------------------------------
# 0. Non-interactive mode
# -----------------------------------------------------------------------------
export DEBIAN_FRONTEND=noninteractive

# -----------------------------------------------------------------------------
# 1. Base system packages
# -----------------------------------------------------------------------------
apt-get update && apt-get install -y \
    build-essential \
    git \
    curl \
    wget \
    zip \
    unzip \
    tar \
    ca-certificates \
    pkg-config \
    rsync \
    python3 \
 && rm -rf /var/lib/apt/lists/*

echo "=== [01] System setup complete ==="
