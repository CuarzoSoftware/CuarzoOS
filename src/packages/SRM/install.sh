#!/bin/bash

apt install meson -y || exit 1
apt install cmake build-essential libdrm-dev libegl-dev mesa-common-dev libgles2-mesa-dev -y || exit 1
apt install libdrm-dev libgbm-dev libevdev-dev libinput-dev libxcursor-dev libxkbcommon-dev -y || exit 1
apt install libxfixes-dev libxrandr-dev libpixman-1-dev libwayland-dev libseat-dev meson -y || exit 1
apt install wget unzip tar edid-decode curl -y || exit 1

mkdir -p /usr/include/drm/
cp /usr/include/libdrm/* /usr/include/drm/

wget https://github.com/vcrhonek/hwdata/archive/refs/heads/master.zip || exit 1

unzip master.zip

cd hwdata-master
./configure
make download
make download
make install

cd ..
rm -r hwdata-master
rm master.zip

wget https://gitlab.freedesktop.org/emersion/libdisplay-info/-/archive/main/libdisplay-info-main.zip || exit 1
unzip libdisplay-info-main.zip
cd libdisplay-info-main
meson setup build -Dbuildtype=release || exit 1
cd build
meson install || exit 1
cd ..
cd ..
rm libdisplay-info-main.zip
rm -r libdisplay-info-main

wget https://github.com/CuarzoSoftware/SRM/archive/refs/heads/main.zip || exit 1
unzip main.zip

cd SRM-main/src/
meson setup build -Dbuildtype=release || exit 1
cd build
meson install || exit 1
cd ../../../
rm -r SRM-main
rm main.zip