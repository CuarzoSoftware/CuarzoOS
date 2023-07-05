#!/bin/bash

sudo debootstrap --arch=$CUARZO_ARCH $CUARZO_DEBIAN_CODENAME $CUARZO_WORKSPACE/bootstrap $CUARZO_DEBIAN_REPO || exit 1