#!/bin/bash
echo "Setting up Zlib"

tar -xvf ${SOURCE_DIR}/zlib-1.2.11.tar.gz
CURRENT_DIR=$(pwd)
cd ${SOURCE_DIR}/zlib-1.2.11

sed -i 's/-O3/-Os/g' configure
./configure --prefix=/usr --shared
make && make DESTDIR=${BUILD_DIR}/ install

mv -v ${BUILD_DIR}/usr/lib/libz.so.* ${BUILD_DIR}/lib
ln -svf ../../lib/libz.so.1 ${BUILD_DIR}/usr/lib/libz.so
ln -svf ../../lib/libz.so.1 ${BUILD_DIR}/usr/lib/libz.so.1
ln -svf ../lib/libz.so.1 ${BUILD_DIR}/lib64/libz.so.1

cd ${CURRENT_DIR}
echo "Zlib installed, Next: source tarbal-source.sh"