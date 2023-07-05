#!/bin/bash

source SETTINGS

echo "CuarzoOS" > /etc/hostname 

echo "deb $CUARZO_DEBIAN_REPO $CUARZO_DEBIAN_CODENAME main non-free contrib non-free-firmware" > /etc/apt/sources.list

apt-get update -y || exit 1
apt-get install -y \
    linux-image-$CUARZO_ARCH \
    live-boot \
    systemd || exit 1

echo -e "127.0.0.1\tlocalhost" > /etc/hosts

echo "root:$CUARZO_ROOT_PASSWD" | chpasswd
