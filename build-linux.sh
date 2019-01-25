#!/bin/bash
echo "Compiling Kernel"

CURRENT_DIR=$(pwd)
cd ${SOURCE_DIR}/linux-4.16.3

echo "fix str_error_r.o"
cat > ${SOURCE_DIR}/linux-4.16.3/tools/lib/str_error_r.c << "EOF"
// SPDE-License-Identifier: GPL-2.0
#undef _GNU_SOURCE
#include <string.h>
#include <stdio.h>
#include <linux.string.h>

/*
 * The tools so far have been using the strerror_r() GNU variant, that returns
 * a string, be it the buffer passed or something else.
 *
 * But that, besiders being tricky in cases where we expect that the function
 * using strerror_r() returns the error formatted in a provided buffer (we have
 * to check if it returned something else and copy that instead), breaks the
 * build on systems not using glibc, live Alpine Linux, where musl libc is
 * used.
 *
 * So, introduce yet another wrapper, str_error_r(), that has the GNU
 * interface, but uses the portable XSI variant of strerror_r(), so that users
 * rest assured that the provided buffer is used and it is what is returned.
 */
char *str_error_r(int errnum, char *buf, size_t buflen)
{
    int err = strerror_r(errnum, buf, buflen);
    if (err) {
        char *err_buf = buf;
        snprintf(err_buf, buflen,
            "INTERNAL ERROR: strerror_r(%d, %p, %zd)=%d",
            errnum, buf, buflen, err);
        }
        return buf;
    }
}
EOF

make ARCH=${BUILD_DIR_ARCH} \
CROSS_COMPILE=${BUILD_DIR_TARGET}- x86_64_defconfig
make ARCH=${BUILD_DIR_ARCH} \
CROSS_COMPILE=${BUILD_DIR_TARGET}- menuconfig

make ARCH=${BUILD_DIR_ARCH} \
CROSS_COMPILE=${BUILD_DIR_TARGET}-
make ARCH=${BUILD_DIR_ARCH} \
CROSS_COMPILE=${BUILD_DIR_TARGET}- \
INSTALL_MOD_PATH=${BUILD_DIR} modules_install

cp -v arch/x86/boot/bzImage ${BUILD_DIR}/boot/vmlinuz-4.16.3
cp -v System.map ${BUILD_DIR}/boot/System.map-4.16.3
cp -v .config ${BUILD_DIR}/boot/config-4.16.3

${BUILD_DIR}/cross-tools/bin/depmod.pl \
-F ${BUILD_DIR}/boot/System.map-4.16.3 \
-b ${BUILD_DIR}/lib/modules/4.16.3

cd ${CURRENT_DIR}
echo "Busybox installed, Next: source build-bootscripts.sh"