# MotionLCM Docker Contract (Env-Only Image)

This document explains the **contract** between:

* the Docker image
* the MotionLCM code repository
* the datasets and pretrained assets

The goal is **full decoupling**:

* the image contains *only* the environment
* code and data are mounted at runtime
* no rebuilding is needed when code changes

If this contract is satisfied, MotionLCM will run exactly as described in its README.

---

## 1. Design philosophy

We explicitly separate the system into **three independent entities**:

### (1) Docker image — *environment only*

Contains:

* Ubuntu 22.04
* CUDA runtime
* PyTorch + micromamba environment
* system dependencies

Does **NOT** contain:

* ❌ MotionLCM code
* ❌ HumanML3D dataset
* ❌ MotionLCM pretrained assets

The image is slow-changing and reusable across machines.

---

### (2) MotionLCM repository — *code*

A normal Git repository that you can:

* edit freely
* switch branches / commits
* add VGM-bench glue code

The image does **not** clone or pin this repo.

---

### (3) Data — *large, static*

Two datasets:

* **HumanML3D** (processed)
* **MotionLCM pretrained assets**

These are uploaded once per machine and reused across runs.

---

## 2. The container contract (authoritative)

At runtime, the container **assumes** the following paths exist:

```text
/opt/code/MotionLCM           # MotionLCM code repository
/opt/datasets/HumanML3D       # HumanML3D dataset
/opt/assets/MotionLCM         # MotionLCM pretrained assets
```

Nothing else is assumed.

If these paths are present, the container will work.

---

## 3. How the contract is enforced

The contract is fully defined by **two mechanisms**:

### (A) Bind mounts (external reality)

Bind mounts map host paths to the container paths above.

Example (host → container):

```text
/home/ubuntu/code/MotionLCM            → /opt/code/MotionLCM
/home/ubuntu/scratch/data/HumanML3D    → /opt/datasets/HumanML3D
/home/ubuntu/scratch/data/MotionLCM_assets → /opt/assets/MotionLCM
```

These mounts are provided by `docker run -v ...` or `apptainer exec --bind ...`.

---

### (B) `motionlcm_entrypoint.sh` (internal semantics)

The container entrypoint performs **lightweight wiring** so that
the MotionLCM code sees the layout expected by its original README.

Specifically, it creates symbolic links:

```text
/opt/code/MotionLCM/deps
    → /opt/assets/MotionLCM/deps

/opt/code/MotionLCM/experiments_recons
/opt/code/MotionLCM/experiments_t2m
/opt/code/MotionLCM/experiments_control
    → /opt/assets/MotionLCM/experiments_*

/opt/code/MotionLCM/datasets/humanml3d
    → /opt/datasets/HumanML3D
```

No files are copied.
No data is duplicated.
Everything is wired at container startup.

---

## 4. Canonical run command (Docker)

On a GPU VM (e.g. Lambda Cloud):

```bash
docker run --rm --gpus all \
  -v /home/ubuntu/code/MotionLCM:/opt/code/MotionLCM \
  -v /home/ubuntu/scratch/data/HumanML3D:/opt/datasets/HumanML3D \
  -v /home/ubuntu/scratch/data/MotionLCM_assets:/opt/assets/MotionLCM \
  haruhikage/motionlcm:v1 \
  /opt/micromamba/bin/micromamba run \
    -p /opt/micromamba/envs/motionlcm \
    python demo.py --cfg configs/motionlcm_control_s.yaml
```

Only the **host paths** change across machines.

---

## 5. Canonical run command (Compute Canada / Apptainer)

On CC Vulcan (example):

```bash
apptainer exec --nv \
  --bind /home/tomori/code/MotionLCM:/opt/code/MotionLCM \
  --bind /home/tomori/scratch/data/HumanML3D:/opt/datasets/HumanML3D \
  --bind /home/tomori/scratch/data/MotionLCM_assets:/opt/assets/MotionLCM \
  motionlcm.sif \
  /opt/micromamba/bin/micromamba run \
    -p /opt/micromamba/envs/motionlcm \
    python demo.py --cfg configs/motionlcm_control_s.yaml
```

Again, only host paths differ.

---

## 6. Why this design

This contract provides:

* **Fast iteration** — edit code, rerun immediately
* **Reproducibility** — freeze commits and image tags when needed
* **Portability** — same image works on Lambda and CC
* **Simplicity** — only three mounts to remember
* **Scalability** — clean SLURM / Apptainer scripts

This is the intended foundation for **VGM-bench**.

---

## 7. When to break the contract (rare)

Only for:

* archival / paper release images
* fully frozen experiments

In that case, code may be copied into the image and pinned to a commit.
During development, **do not** do this.

---

## 8. Mental checklist (for future you)

If something breaks, check:

1. Are all three mounts present?

   * code
   * dataset
   * assets
2. Did the entrypoint create the expected symlinks?

   ```bash
   ls -l /opt/code/MotionLCM
   ```

If yes, MotionLCM should behave exactly like the upstream README.

---

**This README + `motionlcm_entrypoint.sh` define the contract.
Everything else is an implementation detail.**
