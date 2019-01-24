#!/bin/bash
echo "Compressing entire build for archival and installation"
CURRENT_DIR=$(pwd)
cp -rf ${BUILD_DIR}/ ${BUILD_DIR}-copy
rm -rfv ${LJOS}-copy/cross-tools
rm -rfv ${LJOS}-copy/usr/src/*

FILES="$(ls ${LJOS}-copy/usr/lib64/*.a)"
for file in $FILES; do
  rm -f $file
done

find ${LJOS}-copy/{,usr/}{bin,lib,sbin} -type f -exec sudo strip --strip-debug '{}' ';'
find ${LJOS}-copy/{,usr/}lib64 -type f -exec sudo strip --strip-debug '{}' ';'

sudo chown -R root:root ${LJOS}-copy
sudo chgrp 13 ${LJOS}-copy/var/run/utmp ${LJOS}-copy/var/log/lastlog
sudo mknod -m 0666 ${LJOS}-copy/dev/null c 1 3
sudo mknod -m 0600 ${LJOS}-copy/dev/console c 5 1
sudo chmod 4755 ${LJOS}-copy/bin/busybox

cd {LJOS}-copy/
sudo tar cfJ ../darkbien-minimal-build-24January2019.tar.xz *
DARKBIEN_TAR_DIR=$(pwd)

cd ${CURRENT_DIR}
echo "Compressed, Next: mount a drive you want to install on with a fresh ext4 filesystem"
echo "  cd to it"
echo "  export NEW_ROOT_DIR=\$(pwd)"
echo "  and sudo tar xJF \${DARKBIEN_TAR_DIR}/darkbien-minimal-build-24January2019.tar.xz"
echo "  from there, grub-install --root-directory=\${NEW_ROOT_DIR} /dev/{thing you mounted}"
echo "  reboot, loading from that device, and use passwd to set root's password."