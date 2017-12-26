#!/bin/bash -x
cd "$(dirname "$0")"

# Change the following to match your environment:
DB_SERVER=127.0.0.1
DB_PORT=1521
DB_SID=orcl122
DB_USER=scott
DB_PASS=tiger

RASTER_DATA=../../../../data/11-georaster/tiff
RASTER_LIB=../../../../lib
LOAD_PARAMETERS=$1

CLASSPATH=$ORACLE_HOME/ord/jlib/jai_codec.jar:$ORACLE_HOME/ord/jlib/jai_core.jar:$ORACLE_HOME/jdbc/lib/ojdbc8.jar:$ORACLE_HOME/jlib/orai18n.jar:$ORACLE_HOME/rdbms/jlib/xdb.jar:$ORACLE_HOME/lib/xmlparserv2.jar:$ORACLE_HOME/lib/xmlcomp.jar:$ORACLE_HOME/lib/xschema.jar:$ORACLE_HOME/jlib/jewt4.jar:$ORACLE_HOME/md/jlib/sdoapi.jar:$ORACLE_HOME/md/jlib/sdoutl.jar:$RASTER_LIB/georaster_tools.jar

JAVA=$ORACLE_HOME/jdk/bin/java
JAVA_PROPS=-Xms128m -Xmx128m -Duser.language=EN -Duser.region=US

# Load the orthophotos in one step
echo Loading rasters from $RASTER_DATA 
echo Load parameters = $LOAD_PARAMETERS
$ORACLE_HOME/jdk/bin/java $JAVA_PROPS -cp $CLASSPATH oracle.spatial.georaster.tools.GeoRasterLoader $DB_SERVER $DB_SID $DB_PORT $DB_USER $DB_PASS thin 32 T us_rasters georaster $LOAD_PARAMETERS "$RASTER_DATA/sf1.tif,1,us_rasters_rdt_01,$RASTER_DATA/sf1.tfw,26943" "$RASTER_DATA/sf2.tif,2,us_rasters_rdt_01,$RASTER_DATA/sf2.tfw,26943" "$RASTER_DATA/sf3.tif,3,us_rasters_rdt_01,$RASTER_DATA/sf3.tfw,26943" "$RASTER_DATA/sf4.tif,4,us_rasters_rdt_01,$RASTER_DATA/sf4.tfw,26943"
