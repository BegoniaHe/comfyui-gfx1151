#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
IMAGE_NAME=comfyui-gfx1151:local
CONTAINER_NAME=comfyui-gfx1151

cd "$SCRIPT_DIR"

if ! podman image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
  podman build -t "$IMAGE_NAME" .
fi

if podman container exists "$CONTAINER_NAME"; then
  podman start -ai "$CONTAINER_NAME"
  exit 0
fi

podman run -it \
  --cap-add=SYS_PTRACE \
  --security-opt seccomp=unconfined \
  --device=/dev/kfd \
  --device=/dev/dri \
  --group-add video \
  --group-add render \
  --ipc=host \
  -e TORCH_ROCM_AOTRITON_ENABLE_EXPERIMENTAL=1 \
  -p 8188:8188 \
  -v "$SCRIPT_DIR"/ComfyUI:/opt/ComfyUI \
  --shm-size 8G \
  --name "$CONTAINER_NAME" \
  "$IMAGE_NAME"
