#!/bin/bash

source SETTINGS

export CUARZO_SRC_DIR=$(pwd)

mkdir -p $CUARZO_WORKSPACE
mkdir -p $CUARZO_WORKSPACE/completed/{host,chroot,packages}
mkdir -p $CUARZO_WORKSPACE/bootstrap
mkdir -p $CUARZO_WORKSPACE/bootstrap/scripts
mkdir -p $CUARZO_WORKSPACE/bootstrap/packages
mkdir -p $CUARZO_WORKSPACE/{scratch,image/live}
sudo cp scripts/chroot/* $CUARZO_WORKSPACE/bootstrap/scripts
sudo cp -r -p packages/ $CUARZO_WORKSPACE/bootstrap
sudo cp SETTINGS $CUARZO_WORKSPACE/bootstrap/scripts

hostRun() {

    COMPLETED_FILE=$CUARZO_WORKSPACE/completed/host/$1

    if test -v 2; then
        sudo rm $COMPLETED_FILE
    fi

    if ! test -e $COMPLETED_FILE; then

        scripts/host/./$1.sh

        if [ $? -eq 0 ]; then
            echo -e "\e[1m\e[32mSUCCESS:\e[0m \e[1m$1\e[0m host script finished successfully."
            touch $COMPLETED_FILE
        else
            echo -e "\e[1m\e[31mERROR:\e[0m \e[1m$1\e[0m host script failed."
            exit 1
        fi

    else
        echo -e "\e[1m\e[32mSUCCESS:\e[0m \e[1m$1\e[0m host script already executed."
    fi
}

chrootRun() {

    COMPLETED_FILE=$CUARZO_WORKSPACE/completed/chroot/$1

    if test -v 2; then
        sudo rm $COMPLETED_FILE
    fi

    if test -e $COMPLETED_FILE; then
        echo -e "\e[1m\e[32mSUCCESS:\e[0m \e[1m$1\e[0m chroot script already executed."
        return
    fi

    sudo mkdir -pv $CUARZO_WORKSPACE/bootstrap/{dev,proc,sys,run,tmp}
    sudo mount -v --bind /dev $CUARZO_WORKSPACE/bootstrap/dev
    sudo mount -v --bind /dev/pts $CUARZO_WORKSPACE/bootstrap/dev/pts
    sudo mount -vt proc proc $CUARZO_WORKSPACE/bootstrap/proc
    sudo mount -vt sysfs sysfs $CUARZO_WORKSPACE/bootstrap/sys
    sudo mount -vt tmpfs tmpfs $CUARZO_WORKSPACE/bootstrap/run

    if [ -h $CUARZO_WORKSPACE/bootstrap/dev/shm ]; then
        sudo mkdir -pv $CUARZO_WORKSPACE/bootstrap/$(readlink $CUARZO_WORKSPACE/bootstrap/dev/shm)
    else
        sudo mount -t tmpfs -o nosuid,nodev tmpfs $CUARZO_WORKSPACE/bootstrap/dev/shm
    fi
    
    sudo chroot $CUARZO_WORKSPACE/bootstrap bash -c "cd /scripts; ./$1.sh"
    RET=$?

    sudo umount $CUARZO_WORKSPACE/bootstrap/dev/shm
    sudo umount $CUARZO_WORKSPACE/bootstrap/dev/pts
    sudo umount $CUARZO_WORKSPACE/bootstrap/dev
    sudo umount $CUARZO_WORKSPACE/bootstrap/proc
    sudo umount $CUARZO_WORKSPACE/bootstrap/run
    sudo umount $CUARZO_WORKSPACE/bootstrap/sys

    if [ $RET -eq 0 ]; then
        touch $COMPLETED_FILE
        echo -e "\e[1m\e[32mSUCCESS:\e[0m \e[1m$1\e[0m chroot script finished successfully."
    else
        echo -e "\e[1m\e[31mERROR:\e[0m \e[1m$1\e[0m chroot script failed."
        exit 1
    fi
}

chrootInstall() {

    COMPLETED_FILE=$CUARZO_WORKSPACE/completed/packages/$1

    if test -v 2; then
        sudo rm $COMPLETED_FILE
    fi

    if test -e $COMPLETED_FILE; then
        echo -e "\e[1m\e[32mSUCCESS:\e[0m \e[1m$1\e[0m package already installed."
        return
    fi

    sudo mkdir -pv $CUARZO_WORKSPACE/bootstrap/{dev,proc,sys,run,tmp}
    sudo mount -v --bind /dev $CUARZO_WORKSPACE/bootstrap/dev
    sudo mount -v --bind /dev/pts $CUARZO_WORKSPACE/bootstrap/dev/pts
    sudo mount -vt proc proc $CUARZO_WORKSPACE/bootstrap/proc
    sudo mount -vt sysfs sysfs $CUARZO_WORKSPACE/bootstrap/sys
    sudo mount -vt tmpfs tmpfs $CUARZO_WORKSPACE/bootstrap/run

    if [ -h $CUARZO_WORKSPACE/bootstrap/dev/shm ]; then
        sudo mkdir -pv $CUARZO_WORKSPACE/bootstrap/$(readlink $CUARZO_WORKSPACE/bootstrap/dev/shm)
    else
        sudo mount -t tmpfs -o nosuid,nodev tmpfs $CUARZO_WORKSPACE/bootstrap/dev/shm
    fi
    
    sudo chroot $CUARZO_WORKSPACE/bootstrap bash -c "cd /packages/$1; ./install.sh"
    RET=$?

    sudo umount $CUARZO_WORKSPACE/bootstrap/dev/shm
    sudo umount $CUARZO_WORKSPACE/bootstrap/dev/pts
    sudo umount $CUARZO_WORKSPACE/bootstrap/dev
    sudo umount $CUARZO_WORKSPACE/bootstrap/proc
    sudo umount $CUARZO_WORKSPACE/bootstrap/run
    sudo umount $CUARZO_WORKSPACE/bootstrap/sys

    if [ $RET -eq 0 ]; then
        touch $COMPLETED_FILE
        echo -e "\e[1m\e[32mSUCCESS:\e[0m \e[1m$1\e[0m package installed successfully."
    else
        echo -e "\e[1m\e[31mERROR:\e[0m \e[1m$1\e[0m package install failed."
        exit 1
    fi
}