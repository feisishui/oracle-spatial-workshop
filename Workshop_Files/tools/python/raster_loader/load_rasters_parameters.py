import logging

#----------------------------------------------------------------
# Configuration parameters. Change to match your environment
#----------------------------------------------------------------

# Database connection string
DB_CONNECTION='scott/tiger@localhost:1521/orcl121'

# Name of raster catalog 
RASTER_CATALOG='RASTER_CATALOG'

# Name of raster table and georaster column to load into
RASTER_TABLE='US_RASTERS'
RASTER_COLUMN='GEORASTER'

# Name of RDT table(s). Assumed to be <raster_table>_RDT_<nn>
RDT_PATTERN=RASTER_TABLE+'_RDT_'
# Number of RDTs to use. 
# The RDT tables will be called <raster_table>_RDT_01, <raster_table>_RDT_02 etc
# IMPORTANT: better to pre-create the RDTs. If not, the missing tables will be created
# automatically, but not with the right parameters (logging, size, tablespace etc).
NUM_RDTS=4

# Top level directory for rasters to load
# The load will recurse in all sub-directories !
RASTER_DATA='/media/sf_Workshop_Files/data/11-georaster/'

# List of file types to load
RASTER_PATTERN=['.jpg','.jpeg','.tif','.tiff','.jp2']

# Number of parallel processes to use
NUM_PROCESSES=6

# Load parameters
LOAD_PARAMS='-co blocking=optimalpadding -co blockxsize=512 -co blockysize=512 -co blockbsize=3 -co interleave=bip'

# Logging level. Specify as one of:
#   logging.DEBUG
#   logging.INFO
#   logging.WARNING
#   logging.ERROR
#   logging.CRITICAL
LOGGING_LEVEL=logging.INFO

# GDAL debugging
CPL_DEBUG='OFF'
# GDAL memory use (in MB)
GDAL_CACHEMAX='512'

# Catalog creation script
CATALOG_CREATION_DDL='create_raster_catalog.sql'
