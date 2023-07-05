#!/bin/bash

if [ -z "$1" ]; then
    echo "Missing argument"
    echo "Usage:"
    echo "  ./persistent-usb.sh /dev/sdb"
    exit 1
fi

source SETTINGS

sudo umount ${1}1
sudo umount ${1}2

sudo parted --script $1 \
    mklabel msdos \
    mkpart primary 0% 128MiB \
    set 1 boot on \
    mkpart primary 128MiB 10%

sudo mkfs.vfat -F 32 -n LFS-BOOT ${1}1
sudo mkfs.ext4 -F -L LFS-ROOT ${1}2

sudo rm -r /mnt/lfs-boot
sudo mkdir -p /mnt/lfs-boot
sudo mount -o umask=000 ${1}1 /mnt/lfs-boot

# Write the MBR and install the grub files required for legacy BIOS boot on the drive :
sudo grub-install --no-floppy --boot-directory=/mnt/lfs-boot/boot --target=i386-pc $1

# Install /EFI/BOOT/BOOTX64.EFI and other grub files required to load grub from a 64-bit UEFI firmware :
sudo grub-install --removable --boot-directory=/mnt/lfs-boot/boot --efi-directory=/mnt/lfs-boot --target=x86_64-efi $1

# Install /EFI/BOOT/BOOTIA32.EFI and other grub files required for 32-bit UEFI :
sudo grub-install --removable --boot-directory=/mnt/lfs-boot/boot --efi-directory=/mnt/lfs-boot --target=i386-efi $1

# Copy grub.cfg file
sudo mkdir -p /mnt/lfs-boot/boot/grub/
sudo cp resources/grub.cfg /mnt/lfs-boot/boot/grub/grub.cfg

# Set up initramfs
#mkdir initramfs
#gcc -o initramfs/init resources/initramfs-init.c --static -l:libblkid.a

#cd initramfs
#find . | sort | cpio -o -H newc -R 0:0 | gzip -9 > /mnt/lfs-boot/boot/initrd.img
#cd ../
#rm -r initramfs

# Copy kernel
#sudo cp $LFS/boot/vmlinuz-6.1.11-lfs-r11.2-332-systemd /mnt/lfs-boot/vmlinuz

sudo rm -r /mnt/lfs-root
sudo mkdir /mnt/lfs-root
sudo mount ${1}2 /mnt/lfs-root

# Copy LFS to usb
echo "Copying LFS to usb"
sudo cp -r -p $CUARZO_WORKSPACE/bootstrap/. /mnt/lfs-root
sync
echo "Copy finished"
sync

# Changes LFS dirs ownership to the root user
LFS=/mnt/lfs-root

sudo chown -R root:root $LFS/{usr,lib,var,etc,bin,sbin}
case $(uname -m) in
  x86_64) sudo chown -R root:root $LFS/lib64 ;;
esac

sudo umount /mnt/lfs-boot
sudo umount /mnt/lfs-root