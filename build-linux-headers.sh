#!/bin/bash
echo "Uncompressing linux 4.16.3"

tar -xvf ${SOURCE_DIR}/linux-4.16.3.tar.gz
CURRENT_DIR=$(pwd)
cd ${SOURCE_DIR}/linux-4.16.3

make mrproper
make ARCH=${BUILD_DIR_ARCH} headers_check && make ARCH=${BUILD_DIR_ARCH} INSTALL_HDR_PATH=dest headers_install
cp -rv dest/include/* ${BUILD_DIR}/usr/include

cd ${CURRENT_DIR}
echo "Headers installed, Next: source build-binutils.sh"