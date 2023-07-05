#!/bin/bash

wget https://raw.githubusercontent.com/CuarzoSoftware/CuarzoOSResources/main/Packed/Icons/Vector/Ionicons.tar.xz || exit 1
tar -xf Ionicons.tar.xz || exit 1
mkdir -p /System/Resources/Icons/Vector || exit 1
cp -r Ionicons /System/Resources/Icons/Vector || exit 1
rm -r Ionicons
rm Ionicons.tar.xz || exit 1