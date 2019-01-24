#!/bin/bash
echo "Uncompressing Busybox"

tar -xvf ${SOURCE_DIR}/busybox-1.28.3.tar.bz2
CURRENT_DIR=$(pwd)
cd ${SOURCE_DIR}/busybox-1.28.3

make CROSS_COMPILE="${BUILD_DIR_TARGET}-" defconfig
make CROSS_COMPILE="${BUILD_DIR_TARGET}-" menuconfig
make CROSS_COMPILE="${BUILD_DIR_TARGET}-"
make CROSS_COMPILE="${BUILD_DIR_TARGET}-" \
CONFIG_PREFIX="${BUILD_DIR}" install

cp -v examples/depmod.pl ${BUILD_DIR}/cross-tools/bin
chmod 755 ${BUILD_DIR}/cross-tools/bin/depmod.pl

cd ${CURRENT_DIR}
echo "Busybox installed, Next: source build-linux.sh"