#!/bin/bash -x
cd "$(dirname "$0")"

# Cleanup
rm -r -f ogs

# Create unpack directory for the archive
mkdir ogs

# Unpack the archive into the directory
cd ogs
jar -vxf ../ogs-3.1.2.2.zip

# Fixup permissions for executables and scripts
chmod +x glassfish3/bin/*

read -p "Hit return to continue... "
