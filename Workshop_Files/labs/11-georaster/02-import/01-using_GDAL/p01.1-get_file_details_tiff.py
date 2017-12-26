#!/usr/bin/python
import os
import sys

CWD = os.path.dirname(os.path.realpath(sys.argv[0]))

RASTER_FILES = CWD+'/../../../../data/11-georaster/tiff'

print ('Checking files from '+RASTER_FILES)
for root, dirs, filenames in os.walk(RASTER_FILES):
    for f in filenames:
        if f.endswith('.tif'):
            print('=================================================')
            print('Information for file: '+f)
            print('=================================================')
            os.system ('gdalinfo '+os.path.join(root, f))

raw_input('Hit return to continue...')
