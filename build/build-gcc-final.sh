#!/bin/bash
echo "Finializing gcc"

CURRENT_DIR=$(pwd)
cd ${SOURCE_DIR}/gcc-7.3.0

mkdir gcc-build
cd gcc-build

AR=ar LDFLAGS="-Wl,-rpath,${BUILD_DIR}/cross-tools/lib" \
../configure --prefix=${BUILD_DIR}/cross-tools \
--build=${BUILD_DIR_HOST} --target=${BUILD_DIR_TARGET} \
--host=${BUILD_DIR_HOST} --with-sysroot=${BUILD_DIR} \
--disable-nls --enable-shared \
--enable-languages=c,c++ --enable-c99 \
--enable-long-long \
--with-mpfr-include=$(pwd)/../mpfr/src \
--with-mpfr-lib=$(pwd)/mpfr/src/.libs \
--disable-multilib --with-arch=${BUILD_DIR_CPU}
make && make install
cp -v ${BUILD_DIR}/cross-tools/${BUILD_DIR_TARGET}/lib64/libgcc_s.so.1 ${BUILD_DIR}/lib64

export CC="${BUILD_DIR_TARGET}-gcc"
export CXX="${BUILD_DIR_TARGET}-g++"
export CPP="${BUILD_DIR_TARGET}-gcc -E"
export AR="${BUILD_DIR_TARGET}-ar"
export AS="${BUILD_DIR_TARGET}-as"
export LD="${BUILD_DIR_TARGET}-ld"
export RANLIB="${BUILD_DIR_TARGET}-ranlib"
export READELF="${BUILD_DIR_TARGET}-readelf"
export STRIP="${BUILD_DIR_TARGET}-strip"

cd ${CURRENT_DIR}
echo "Gcc Final installed, Next: source build-busybox.sh"