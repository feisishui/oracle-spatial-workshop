#!/bin/bash -x
cd "$(dirname "$0")"

# Cleanup
rm -r mapviewer_ogs
rm mapviewer_ogs.ear

# Create unpack directory for the ear file
mkdir mapviewer_ogs

# Unpack the ear file into the directory
cd mapviewer_ogs
jar -xvf ../mapviewer.ear

# Create unpack directory for the war file
mkdir web

# Unpack the war file into the directory
cd web
jar -xvf ../web.war

# Copy glassfish-web.xml into WEB-INF
mv WEB-INF/web.xml WEB-INF/web.xml.orig
cp WEB-INF/glassfish-web.xml WEB-INF/web.xml

# Repack the war file
jar -cvf ../web.war *

# Remove the web directory
cd ..
rm -r web

# Repack the ear file
jar -cvf ../mapviewer_ogs.ear *

# Cleanup
cd ..
rm -r mapviewer_ogs

read -p "Hit return to continue..."
