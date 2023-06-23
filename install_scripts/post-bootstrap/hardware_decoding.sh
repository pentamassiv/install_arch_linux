#!/bin/bash

# Install everything related to grafics
# RX Vega 8 -> GCN 5 Architecture -> AMDGPU driver or AMDGPU PRO (proprietary)
pacman -S --noconfirm --needed mesa vulkan-radeon libva-mesa-driver mesa-vdpau # provide the DRI driver for 3D acceleration, Vulkan support, Support for accelerated video decoding via VA-API and VDPAU
