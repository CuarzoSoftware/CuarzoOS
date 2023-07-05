#!/bin/bash

# install kbd for chvt
apt install weston libfreeimage-dev libfontconfig-dev -y || exit 1

wget https://github.com/CuarzoSoftware/Louvre/archive/refs/heads/devel.zip || exit 1
unzip devel.zip || exit 1

cd Louvre-devel/src/
meson setup build -Dbuildtype=release || exit 1
cd build
meson install || exit 1

cd ../../../

rm -r Louvre-devel
rm devel.zip

cp louvre.sh /bin
cp louvre.service /usr/lib/systemd/system

systemctl enable louvre.service || exit 1
systemctl disable getty@tty1.service || exit 1