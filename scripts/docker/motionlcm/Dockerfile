FROM nvidia/cuda:11.7.1-cudnn8-runtime-ubuntu22.04

# system
RUN bash 01_setup_system.sh
RUN bash 02_install_micromamba_docker.sh

ENV MAMBA_ROOT_PREFIX=/opt/micromamba
ENV PATH=/opt/micromamba/bin:$PATH

# motionlcm env
RUN bash motionlcm-03a_install_system_deps.sh
RUN bash motionlcm-03b-create_env.sh
RUN bash motionlcm-03c_fix_cxxabi.sh

# code
RUN bash motionlcm-04_clone_repo.sh

# runtime env
ENV LD_LIBRARY_PATH=/opt/micromamba/envs/motionlcm/lib:$LD_LIBRARY_PATH
WORKDIR /opt/repos/MotionLCM
