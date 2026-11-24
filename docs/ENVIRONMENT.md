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
| Python | to be decided | installed through uv, not the system Python |
| PyTorch | to be decided | wheels built for CUDA 12.1 |

## Packages

One row per direct dependency declared in `pyproject.toml`. Transitive dependencies are only in
`uv.lock`.

| Package | Version constraint | Needed for | Why this version |
|---|---|---|---|
| (none yet) | | | |

## Compiled extensions

OpenPCDet ships CUDA/C++ extensions that are compiled on each machine and are therefore not covered
by `uv.lock`. Build instructions and the tested compiler versions will be recorded here.

## Setup steps

To be written as the environment is built. The goal is a single documented sequence
(load compiler and CUDA, `uv sync`, build extensions) that reproduces the environment on a new
machine.
