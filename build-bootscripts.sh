#!/bin/bash
echo "Setting up bootscripts"

tar -xvf ${SOURCE_DIR}/clfs-embedded-bootscripts-1.0-pre3.tar.bz2
CURRENT_DIR=$(pwd)
cd ${SOURCE_DIR}/clfs-embedded-bootscripts-1.0-pre3

make DESTDIR=${BUILD_DIR}/ install-bootscripts
ln -sv ../rc.d/startup ${BUILD_DIR}/etc/init.d/rcS

cd ${CURRENT_DIR}
echo "Bootscripts installed, Next: source build-zlib.sh"