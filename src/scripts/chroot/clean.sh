#!/bin/bash

source SETTINGS

apt remove wget unzip \
    cmake build-essential libdrm-dev libegl-dev mesa-common-dev libgles2-mesa-dev \
    libdrm-dev libgbm-dev libevdev-dev libinput-dev libxcursor-dev libxkbcommon-dev \
    libxfixes-dev libxrandr-dev libpixman-1-dev libwayland-dev libseat-dev meson \
    libfreeimage-dev libfontconfig-dev -y || exit 1

apt install libdrm-common libegl-mesa0 libgles2-mesa \
    libgbm1 libevdev2 libinput10 libxcursor1 libxkbcommon0 \
    libpixman-1-0 libwayland-server0 libseat1 \
    libfreeimage3 libfontconfig1 -y || exit 1

apt purge -y
apt clean -y
apt autoclean -y
apt autoremove -y

rm -r /scripts
rm -r /packages