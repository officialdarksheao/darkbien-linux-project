#!/bin/bash
echo "Welcome!"
source environment-setup.sh
source download-all.sh

source build/build-linux-headers.sh
source build/build-binutils.sh
source build/build-static-gcc.sh
source build/build-glibc.sh
source build/build-gcc-final.sh
source build/build-busybox.sh
source build/build-linux.sh
source build/build-bootscripts.sh
source build/build-zlib.sh

echo "System Built, Next: source tarbal-source.sh"