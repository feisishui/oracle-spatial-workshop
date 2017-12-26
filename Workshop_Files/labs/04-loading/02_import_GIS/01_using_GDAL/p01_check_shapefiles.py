#!/usr/bin/python
import os
import sys

CWD = os.path.dirname(os.path.realpath(sys.argv[0]))

SHAPE_FILES = CWD+'/../../../../data/04-loading/shape'

for root, dirs, filenames in os.walk(SHAPE_FILES):
    for f in filenames:
        if f.endswith('.shp'):
            print('=================================================')
            print('File: '+f)
            print('=================================================')
            os.system ('ogrinfo -al -so '+os.path.join(root, f))
raw_input('Hit return to continue...')
