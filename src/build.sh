#!/bin/bash

if ! test -e SETTINGS; then
    echo -e "\e[31mERROR:\e[0m Please run the script from the same directory (./build.sh)"
    exit 1
fi

source scripts/host/functions.sh

# Execute /scripts
hostRun install_host_deps
hostRun debootstrap
chrootRun install_kernel
chrootInstall SRM f
chrootInstall Louvre f
chrootInstall Plymouth f
chrootInstall Fonts f
chrootInstall Icons f
chrootRun clean f
hostRun squash f
hostRun mkiso f