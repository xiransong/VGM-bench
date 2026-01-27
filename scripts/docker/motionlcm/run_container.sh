# docker run --rm -it \
#   --gpus all \
#   --shm-size=8g \
#   --ulimit memlock=-1 \
#   --ulimit stack=67108864 \
#   -v /home/ubuntu/scratch/data/MotionLCM_assets:/opt/assets/MotionLCM \
#   -v /home/ubuntu/scratch/data/HumanML3D:/opt/datasets/HumanML3D \
#   haruhikage/motionlcm:v1 \
#   bash

docker run --rm --gpus all \
  --shm-size=8g \
  --ulimit memlock=-1 \
  --ulimit stack=67108864 \
  -v /home/ubuntu/scratch/repos/MotionLCM:/opt/code/MotionLCM \
  -v /home/ubuntu/scratch/data/HumanML3D:/opt/datasets/HumanML3D \
  -v /home/ubuntu/scratch/data/MotionLCM_assets:/opt/assets/MotionLCM \
  haruhikage/motionlcm:v1 \
  /opt/micromamba/bin/micromamba run \
    -p /opt/micromamba/envs/motionlcm \
    python demo.py --cfg configs/motionlcm_control_s.yaml
