#!/bin/bash
echo "Downloading all needed packages into ${SOURCE_DIR}"

wget --input-file=wget-list --continue --directory-prefix=${SOURCE_DIR}

echo "Downloaded! Next: source build-linux-headers.sh"