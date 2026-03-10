#!/bin/bash

IMAGE_NAME=comfyui-gfx1151:local

if ! podman image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
  podman build -t "$IMAGE_NAME" .
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
  -v $(pwd)/ComfyUI:/opt/ComfyUI \
  --shm-size 8G \
  --name comfyui-gfx1151 \
  "$IMAGE_NAME"
