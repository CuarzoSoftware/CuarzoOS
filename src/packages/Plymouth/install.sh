#!/bin/bash

apt install plymouth -y || exit 1

wget https://raw.githubusercontent.com/CuarzoSoftware/CuarzoOSResources/main/Design/Logo/Cuarzo%40128.png || exit 1

mv Cuarzo@128.png CuarzoOS/Cuarzo@128.png
cp -r CuarzoOS /usr/share/plymouth/themes/
cp plymouthd.conf /usr/share/plymouth/plymouthd.defaults
rm CuarzoOS/Cuarzo@128.png
update-initramfs -u || exit 1