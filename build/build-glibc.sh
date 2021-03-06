#!/bin/bash
echo "Uncompressing Glibc"

CURRENT_DIR=$(pwd)
cd ${SOURCE_DIR}
tar -xvf ${SOURCE_DIR}/glibc-2.28.tar.gz
cd ${SOURCE_DIR}/glibc-2.28

mkdir glibc-build
cd glibc-build

echo "libc_cv_forced_unwind=yes" > config.cache
echo "libc_cv_c_cleanup=yes" >> config.cache
echo "libc_cv_ssp=no" >> config.cache
echo "libc_cv_ssp_strong=no" >> config.cache

BUILD_CC="gcc" CC="${BUILD_DIR_TARGET}-gcc" \
AR="${BUILD_DIR_TARGET}-ar" \
RANLIB="${BUILD_DIR_TARGET}-ranlib" CFLAGS="-O2" \
../configure --prefix=/usr \
--host=${BUILD_DIR_TARGET} --build=${BUILD_DIR_HOST} \
--disable-profile --enable-add-ons --with-tls \
--enable-kernel=4.20.5 --with-__thread \
--with-binutils=${BUILD_DIR}/cross-tools/bin \
--with-headers=${BUILD_DIR}/usr/include \
--cache-file=config.cache

make && make install_root=${BUILD_DIR}/ install

cd ${CURRENT_DIR}
echo "Glibc installed, Next: source build-gcc-final.sh"