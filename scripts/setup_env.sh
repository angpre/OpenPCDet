#!/usr/bin/env bash
# Build the Python environment and compile the CUDA extensions of pcdet.
#
# Prerequisites, which must already be on PATH (for example through
# `module load` on a cluster):
#   - uv
#   - gcc / g++
#   - nvcc, from a CUDA toolkit matching the PyTorch build (see docs/ENVIRONMENT.md)
#
# Usage, from anywhere:
#   bash scripts/setup_env.sh
#
# The script is safe to re-run: `uv sync` is a no-op when the environment is
# up to date, and the build only recompiles sources that changed.

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

for tool in uv gcc g++ nvcc; do
    if ! command -v "$tool" > /dev/null; then
        echo "error: '$tool' not found on PATH" >&2
        exit 1
    fi
done

echo "== Toolchain"
echo "uv:   $(uv --version)"
echo "gcc:  $(gcc -dumpfullversion)"
echo "nvcc: $(nvcc --version | grep -o 'release [0-9.]*')"

# 1. Python and all packages, exactly as recorded in uv.lock.
echo "== uv sync"
uv sync --locked

# 2. CUDA extensions, compiled in place next to their Python wrappers.
#    Running through `uv run` puts the environment's `ninja` on PATH, which
#    PyTorch uses to compile the sources in parallel.
echo "== Building CUDA extensions"
uv run --locked python setup.py build_ext --inplace

# 3. Check that every extension can be imported.
echo "== Checking the build"
uv run --locked python -W ignore - <<'PY'
import importlib

import torch

import pcdet

extensions = [
    "pcdet.ops.iou3d_nms.iou3d_nms_cuda",
    "pcdet.ops.roiaware_pool3d.roiaware_pool3d_cuda",
    "pcdet.ops.roipoint_pool3d.roipoint_pool3d_cuda",
    "pcdet.ops.pointnet2.pointnet2_stack.pointnet2_stack_cuda",
    "pcdet.ops.pointnet2.pointnet2_batch.pointnet2_batch_cuda",
    "pcdet.ops.bev_pool.bev_pool_ext",
    "pcdet.ops.ingroup_inds.ingroup_inds_cuda",
]
for name in extensions:
    importlib.import_module(name)

print(f"pcdet {pcdet.__version__}, torch {torch.__version__}, "
      f"CUDA available: {torch.cuda.is_available()}")
print(f"{len(extensions)} CUDA extensions imported")
PY

echo "== Done"
