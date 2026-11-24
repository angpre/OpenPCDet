# Environment

This file records how the Python environment of this repository is built, which packages it
contains and why. The exact resolved versions are in `uv.lock`; this file explains the choices.
It is updated in the same commit as any change to `pyproject.toml`.

This repository is based on [OpenPCDet](https://github.com/open-mmlab/OpenPCDet) at commit
`233f849829b6ac19afb8af8837a0246890908755` (2025-10-08). The changes made to upstream code to
support this environment are visible in the git history after that commit.

## Reference platform

The platform on which the environment is built and tested.

| Component | Version | Notes |
|---|---|---|
| GPU | NVIDIA L40S, 48 GB | one GPU per job |
| CUDA toolkit | 12.1 | needed to compile the CUDA extensions (`nvcc`) |
| GCC | 11.2.0 | compiler for the CUDA extensions |
| uv | 0.11.6 | installs Python and all packages |
| Python | 3.12 | installed through uv (`.python-version`), not the system Python |
| PyTorch | 2.5.1+cu121 | wheels built for CUDA 12.1, from the PyTorch index |
| NVIDIA driver | 595.99 | any driver that supports CUDA 12.1 should work |

## Packages

One row per direct dependency declared in `pyproject.toml`. Transitive dependencies are only in
`uv.lock`.

| Package | Version constraint | Needed for | Why this version |
|---|---|---|---|
| `torch` | `==2.5.1` (cu121 build) | Everything: models, training, the CUDA extensions are compiled against it. | 2.5.1 is the newest PyTorch release published for CUDA 12.1. It is installed from `https://download.pytorch.org/whl/cu121` because PyPI does not host the CUDA 12.1 build. Pinned exactly because the compiled extensions and `spconv` must match it. |
| `torchvision` | `==0.20.1` (cu121 build) | Image backbones (ResNet) with ImageNet weights, image transforms, GPU NMS. | 0.20.1 is the release paired with PyTorch 2.5.1. Installed from the same PyTorch index so that its compiled operators match the CUDA 12.1 build of `torch`. |
| `spconv-cu121` | `==2.3.8` | Sparse 3D/2D convolutions, used by the voxel backbones and sparse detection heads of OpenPCDet. | The package name encodes the CUDA version; `cu121` matches CUDA 12.1. 2.3.8 is the latest release and the first series with Python 3.12 wheels (the older `spconv-cu120` package stops at Python 3.11). Prebuilt wheel from PyPI, so nothing is compiled locally. It brings `cumm-cu121` and `numpy` as dependencies. |

Python 3.12 is the newest Python for which all three binary dependencies that must match CUDA 12.1
have wheels: `torch` 2.5.1 (3.9-3.13), `torchvision` 0.20.1 (3.9-3.12) and `spconv-cu121` 2.3.8
(3.9-3.13).

## Compiled extensions

OpenPCDet ships CUDA/C++ extensions that are compiled on each machine and are therefore not covered
by `uv.lock`. Build instructions and the tested compiler versions will be recorded here.

## Setup steps

To be written as the environment is built. The goal is a single documented sequence
(load compiler and CUDA, `uv sync`, build extensions) that reproduces the environment on a new
machine.
