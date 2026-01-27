# ============================================================
# MotionLCM Environment Image (env-only, decoupled)
# CUDA 11.7 + Ubuntu 22.04
# ============================================================

FROM nvidia/cuda:11.7.1-cudnn8-runtime-ubuntu22.04

# ------------------------------------------------------------
# Global non-interactive setup
# ------------------------------------------------------------
ENV DEBIAN_FRONTEND=noninteractive

# ------------------------------------------------------------
# Copy setup scripts
# ------------------------------------------------------------
WORKDIR /opt/build

COPY 01_setup_system.sh .
COPY 02_install_micromamba.sh .
COPY motionlcm-03a_install_system_deps.sh .
COPY motionlcm-03b-create_env.sh .
COPY motionlcm-03c_fix_cxxabi.sh .
COPY motionlcm_entrypoint.sh /opt/motionlcm_entrypoint.sh

RUN chmod +x *.sh /opt/motionlcm_entrypoint.sh

# ------------------------------------------------------------
# System + Python environment
# ------------------------------------------------------------
RUN ./01_setup_system.sh
RUN ./02_install_micromamba.sh

ENV MAMBA_ROOT_PREFIX=/opt/micromamba
ENV PATH=/opt/micromamba/bin:$PATH

RUN ./motionlcm-03a_install_system_deps.sh
RUN ./motionlcm-03b-create_env.sh
RUN ./motionlcm-03c_fix_cxxabi.sh

# ------------------------------------------------------------
# Runtime environment variables
# ------------------------------------------------------------
ENV LD_LIBRARY_PATH=/opt/micromamba/envs/motionlcm/lib:$LD_LIBRARY_PATH

# ------------------------------------------------------------
# Default runtime directory = MotionLCM repo
# ------------------------------------------------------------
WORKDIR /opt/code/MotionLCM

# ------------------------------------------------------------
# Entrypoint defines the contract
# ------------------------------------------------------------
ENTRYPOINT ["/opt/motionlcm_entrypoint.sh"]
CMD ["bash"]
