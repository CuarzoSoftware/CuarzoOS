#!/bin/bash

cp $CUARZO_WORKSPACE/bootstrap/boot/vmlinuz-* \
    $CUARZO_WORKSPACE/image/vmlinuz && \
cp $CUARZO_WORKSPACE/bootstrap/boot/initrd.img-* \
    $CUARZO_WORKSPACE/image/initrd

cat <<EOF >$CUARZO_WORKSPACE/scratch/grub.cfg

search --set=root --file /DEBIAN_CUSTOM

GRUB_FORCE_HIDDEN_MENU=true
GRUB_HIDDEN_TIMEOUT=0

set default=0
set timeout=0

menu_color_normal=white/dark-gray
menu_color_highlight=light-green/dark-gray

menuentry "CuarzoOS" {
    linux /vmlinuz boot=live quiet splash loglevel=0 systemd.log_level=0 systemd.show_status=0 vt.global_cursor_default=0 vt.cur_default=1
    initrd /initrd
}
EOF

touch $CUARZO_WORKSPACE/image/DEBIAN_CUSTOM

ls -lh $CUARZO_WORKSPACE/
ls -lRh $CUARZO_WORKSPACE/scratch
ls -lRh $CUARZO_WORKSPACE/image

grub-mkstandalone \
    --format=x86_64-efi \
    --output=$CUARZO_WORKSPACE/scratch/grubx64.efi \
    --locales="" \
    --fonts="" \
    "boot/grub/grub.cfg=$CUARZO_WORKSPACE/scratch/grub.cfg"

grub-mkstandalone \
    --format=i386-efi \
    --output=$CUARZO_WORKSPACE/scratch/bootia32.efi \
    --locales="" \
    --fonts="" \
    "boot/grub/grub.cfg=$CUARZO_WORKSPACE/scratch/grub.cfg"

grub-glue-efi \
    --input32=$CUARZO_WORKSPACE/scratch/bootia32.efi \
    --input64=$CUARZO_WORKSPACE/scratch/grubx64.efi \
    --output=$CUARZO_WORKSPACE/scratch/bootx64.efi \

(cd $CUARZO_WORKSPACE/scratch && \
    dd if=/dev/zero of=efiboot.img bs=1M count=30 && \
    mkfs.vfat -F12 efiboot.img && \
    mmd -i efiboot.img EFI EFI/boot && \
    mcopy -i efiboot.img ./bootx64.efi ::EFI/boot/ && \
    mcopy -i efiboot.img ./grubx64.efi ::EFI/boot/ && \
    mcopy -i efiboot.img ./bootia32.efi ::EFI/boot/ 
)

grub-mkstandalone \
    --format=i386-pc \
    --output=$CUARZO_WORKSPACE/scratch/core.img \
    --install-modules="linux normal iso9660 biosdisk memdisk search tar ls" \
    --modules="linux normal iso9660 biosdisk search" \
    --locales="" \
    --fonts="" \
    "boot/grub/grub.cfg=$CUARZO_WORKSPACE/scratch/grub.cfg"

cat \
    /usr/lib/grub/i386-pc/cdboot.img \
    $CUARZO_WORKSPACE/scratch/core.img \
> $CUARZO_WORKSPACE/scratch/bios.img

xorriso \
    -as mkisofs \
    -iso-level 3 \
    -full-iso9660-filenames \
    -volid "DEBIAN_CUSTOM" \
    -eltorito-boot \
        boot/grub/bios.img \
        -no-emul-boot \
        -boot-load-size 4 \
        -boot-info-table \
        --eltorito-catalog boot/grub/boot.cat \
    --grub2-boot-info \
    --grub2-mbr /usr/lib/grub/i386-pc/boot_hybrid.img \
    -eltorito-alt-boot \
        -e EFI/efiboot.img \
        -no-emul-boot \
    -isohybrid-gpt-basdat \
    -append_partition 2 0xef $CUARZO_WORKSPACE/scratch/efiboot.img \
    -output "$CUARZO_SRC_DIR/CuarzoOS-$CUARZO_VERSION-$CUARZO_ARCH.iso" \
    -graft-points \
        "$CUARZO_WORKSPACE/image" \
        /boot/grub/bios.img=$CUARZO_WORKSPACE/scratch/bios.img \
        /EFI/efiboot.img=$CUARZO_WORKSPACE/scratch/efiboot.img

ls -lh $CUARZO_SRC_DIR/*.iso