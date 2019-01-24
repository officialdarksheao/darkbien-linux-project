#!/bin/bash
echo "Compiling Kernel"

CURRENT_DIR=$(pwd)
cd ${SOURCE_DIR}/linux-4.16.3

make ARCH=${BUILD_DIR_ARCH} \
CROSS_COMPILE=${BUILD_DIR_TARGET}- x86_64_defconfig
make ARCH=${BUILD_DIR_ARCH} \
CROSS_COMPILE=${BUILD_DIR_TARGET}- menuconfig

make ARCH=${BUILD_DIR_ARCH} \
CROSS_COMPILE=${BUILD_DIR_TARGET}-
make ARCH=${BUILD_DIR_ARCH} \
CROSS_COMPILE=${BUILD_DIR_TARGET}- \
INSTALL_MOD_PATH=${BUILD_DIR} modules_install

cp -v arch/x86/boot/bzImage ${BUILD_DIR}/boot/vmlinuz-4.16.3
cp -v System.map ${BUILD_DIR}/boot/System.map-4.16.3
cp -v .config ${BUILD_DIR}/boot/config-4.16.3

${BUILD_DIR}/cross-tools/bin/depmod.pl \
-F ${BUILD_DIR}/boot/System.map-4.16.3 \
-b ${BUILD_DIR}/lib/modules/4.16.3

cd ${CURRENT_DIR}
echo "Busybox installed, Next: source build-bootscripts.sh"