#!/bin/bash
echo "Uncompressing gcc"

CURRENT_DIR=$(pwd)
cd ${SOURCE_DIR}
tar -xvf ${SOURCE_DIR}/gcc-7.3.0.tar.xz
cd ${SOURCE_DIR}/gcc-7.3.0

tar xjf ../gmp-6.1.2.tar.bz2
mv gmp-6.1.2 gmp
tar xJf ../mpfr-4.0.1.tar.xz
mv mpfr-4.0.1 mpfr
tar xzf ../mpc-1.1.0.tar.gz
mv mpc-1.1.0 mpc

mkdir gcc-static
cd gcc-static

AR=ar LDFLAGS="-Wl,-rpath,${BUILD_DIR}/cross-tools/lib" \
../gcc-7.3.0/configure --prefix=${BUILD_DIR}/cross-tools \
--build=${BUILD_DIR_HOST} --host=${BUILD_DIR_HOST} \
--target=${BUILD_DIR_TARGET} \
--with-sysroot=${BUILD_DIR}/target --disable-nls \
--disable-shared \
--with-mpfr-include=$(pwd)/../gcc-7.3.0/mpfr/src \
--with-mpfr-lib=$(pwd)/mpfr/src/.libs \
--without-headers --with-newlib --disable-decimal-float \
--disable-libgomp --disable-libmudflap --disable-libssp \
--disable-threads --enable-languages=c,c++ \
--disable-multilib --with-arch=${BUILD_DIR_CPU}
make all-gcc all-target-libgcc && \
make install-gcc install-target-libgcc
ln -vs libgcc.a `${BUILD_DIR_TARGET}-gcc -print-libgcc-file-name | sed 's/libgcc/&_eh/'`

cd ${CURRENT_DIR}
echo "Gcc installed, Next: source build-glibc.sh"