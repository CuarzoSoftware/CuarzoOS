#!/bin/bash

wget https://raw.githubusercontent.com/CuarzoSoftware/CuarzoOSResources/main/Packed/Fonts/Inter.tar.xz || exit 1
tar -xf Inter.tar.xz || exit 1
cp -r Inter /usr/share/fonts/opentype
fc-cache -f -v || exit 1
rm -r Inter
rm Inter.tar.xz