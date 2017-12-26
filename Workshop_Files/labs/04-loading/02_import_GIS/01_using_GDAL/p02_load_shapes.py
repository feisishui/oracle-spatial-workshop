#!/usr/bin/python
import os
import sys

CWD = os.path.dirname(os.path.realpath(sys.argv[0]))

# Change the following to match your environment:
DB_CONNECT='127.0.0.1:1521/orcl122'
DB_USER='scott'
DB_PASS='tiger'

SHAPE_FILES = CWD+'/../../../../data/04-loading/shape'

os.environ['OCI_FID'] ='ID';

# Uncomment the following to enable GDAL tracing
#os.environ['CPL_DEBUG'] ='ON';

print ('Loading shape files from '+SHAPE_FILES)

for root, dirs, filenames in os.walk(SHAPE_FILES):
    for f in filenames:
        if f.endswith('.shp'):
            print('Loading file: '+f)
            # Strip out .shp extension from file name
            # Replace blanks with underscores
            # Also make it upper case
            t = f[:-4].replace(' ','_').upper()
            # Construct the ogr2ogr command
            ogr = (
            'time ogr2ogr -f OCI OCI:%s/%s@%s:%s "%s"'
            ' -nln %s' 
            ' -overwrite'
            ' -progress'
            ' -lco DIM=2 -lco SRID=4326 -lco GEOMETRY_NAME=geom -lco INDEX=NO'
            ' -lco DIMINFO_X="-180,180,1" -lco DIMINFO_Y="-90,90,1"'
            ' -lco LAUNDER=YES'
            % (DB_USER, DB_PASS, DB_CONNECT, t, os.path.join(root, f), t)
            )
            # Execute it
            os.system (ogr)

raw_input('Hit return to continue...')
