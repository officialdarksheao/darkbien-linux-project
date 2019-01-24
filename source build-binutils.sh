#!/bin/bash
echo "Uncompressing binutils"
tar -xvf ${SOURCE_DIR}/binutils-2.30.tar.xz
CURRENT_DIR=$(pwd)
cd ${SOURCE_DIR}/binutils-2.30
mkdir binutils-build
cd binutils-build
../binutils-2.30/configure --prefix=${BUILD_DIR}/cross-tools --target=${BUILD_DIR_TARGET} --with-sysroot=${BUILD_DIR} --disable-nls --enable-shared --disable-multilib
make configure-host && make
ln -sv lib ${BUILD_DIR}/cross-tools/lib64
make install
cp -v ../binutils-2.30/include/libiberty.h ${BUILD_DIR}/usr/include
cd ${CURRENT_DIR}
echo "Binutils installed, Next: source build-static-gcc.sh"