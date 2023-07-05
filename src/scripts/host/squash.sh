#!/bin/bash

sudo rm $CUARZO_WORKSPACE/image/live/filesystem.squashfs

sudo mksquashfs \
    $CUARZO_WORKSPACE/bootstrap \
    $CUARZO_WORKSPACE/image/live/filesystem.squashfs \
    -e boot