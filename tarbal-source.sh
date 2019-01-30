#!/bin/bash
echo "Compressing entire build for archival and installation"
CURRENT_DIR=$(pwd)
cp -rf ${BUILD_DIR}/ ${BUILD_DIR}-copy
rm -rfv ${BUILD_DIR}-copy/cross-tools
rm -rfv ${BUILD_DIR}-copy/usr/src/*

FILES="$(ls ${BUILD_DIR}-copy/usr/lib64/*.a)"
for file in $FILES; do
  rm -f $file
done

find ${BUILD_DIR}-copy/{,usr/}{bin,lib,sbin} -type f -exec sudo strip --strip-debug '{}' ';'
find ${BUILD_DIR}-copy/{,usr/}lib64 -type f -exec sudo strip --strip-debug '{}' ';'

sudo chown -R root:root ${BUILD_DIR}-copy
sudo chgrp 13 ${BUILD_DIR}-copy/var/run/utmp ${BUILD_DIR}-copy/var/log/lastlog
sudo mknod -m 0666 ${BUILD_DIR}-copy/dev/null c 1 3
sudo mknod -m 0600 ${BUILD_DIR}-copy/dev/console c 5 1
sudo chmod 4755 ${BUILD_DIR}-copy/bin/busybox

cd ${BUILD_DIR}-copy/
sudo tar cfJ ../darkbien-minimal-build-30January2019.tar.xz *
DARKBIEN_TAR_DIR=$(pwd)

cd ${CURRENT_DIR}
echo "Compressed, Next: use fdisk or cfdisk to create a gpt partion"
echo "  mount a drive you want to install on with a fresh ext4 filesystem"
echo "  mkfs.ext4 that drive, then use fdisk to set the drive to be bootable"
echo "  cd to it"
echo "  export NEW_ROOT_DIR=\$(pwd)"
echo "  and sudo tar xf \${DARKBIEN_TAR_DIR}/darkbien-minimal-build-30January2019.tar.xz"
echo "  from there, grub-install --root-directory=\${NEW_ROOT_DIR} /dev/{thing you mounted}"
echo "  cp \${NEW_ROOT_DIR}/bootconfig/grub/* \${NEW_ROOT_DIR}/boot/grub/. "
echo "  reboot, loading from that device, and use passwd to set root's password."