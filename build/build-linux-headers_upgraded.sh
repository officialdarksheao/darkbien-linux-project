#!/bin/bash
echo "Uncompressing linux 4.16.3"

CURRENT_DIR=$(pwd)
cd ${SOURCE_DIR}
tar -xvf ${SOURCE_DIR}/linux-4.20.5.tar.gz
cd ${SOURCE_DIR}/linux-4.20.5

make mrproper
make ARCH=${BUILD_DIR_ARCH} headers_check && make ARCH=${BUILD_DIR_ARCH} INSTALL_HDR_PATH=dest headers_install
cp -rv dest/include/* ${BUILD_DIR}/usr/include

cd ${CURRENT_DIR}
echo "Headers installed, Next: source build-binutils.sh"