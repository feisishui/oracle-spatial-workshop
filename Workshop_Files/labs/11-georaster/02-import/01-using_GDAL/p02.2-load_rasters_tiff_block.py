#!/usr/bin/python
import os
import sys


CWD = os.path.dirname(os.path.realpath(sys.argv[0]))

# Change the following to match your environment:
DB_CONNECTION='scott/tiger@localhost:1521/orcl122'
RASTER_TABLE='US_RASTERS'
RASTER_COLUMN='GEORASTER'
RDT='US_RASTERS_RDT_01'

RASTER_DATA = CWD+'/../../../../data/11-georaster/tiff'

# Uncomment the following to enable GDAL tracing
#os.environ['CPL_DEBUG'] ='ON';

os.system ('gdalinfo --version');

i = 1
for root, dirs, filenames in os.walk(RASTER_DATA):
    for f in filenames:
        if f.endswith('.tif'):
            print ('***********************************************************')
            print ('Loading file %d: %s' % (i,f) )
            print ('***********************************************************')
            # Construct the gdal_translate command
            gdal = (
            'time gdal_translate -of georaster %s georaster:%s,%s,%s'
            ' -co insert="(GEORID, SOURCE_FILE, GEORASTER) values (%d, \'%s\', sdo_geor.init(\'%s\'))" '
            ' -co blockxsize=512 -co blockysize=512 -co blockbsize=3 -co interleave=bip'
            % (os.path.join(root, f), DB_CONNECTION, RASTER_TABLE, RASTER_COLUMN, i, f, RDT)
            )
            # Execute it
            os.system (gdal)
            i=i+1

raw_input('Hit return to continue...')
