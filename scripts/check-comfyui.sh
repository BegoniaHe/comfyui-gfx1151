#!/bin/bash

# If the mounted /opt/ComfyUI directory is empty, copy the image-bundled checkout into it.

if [ ! -e /opt/ComfyUI/requirements.txt ]; then
   echo "No ComfyUI detected, copying a built-in (pre-cloned) one..."
   cp -r /opt/ComfyUI-pre-cloned/{.,}* /opt/ComfyUI/
fi
