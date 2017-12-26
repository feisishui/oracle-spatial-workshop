import logging

#----------------------------------------------------------------
# Configuration parameters. Change to match your environment
#----------------------------------------------------------------

# Database connection string
DB_CONNECTION='scott/tiger@localhost:1521/orcl121'

# Name of vector catalog 
VECTOR_CATALOG='VECTOR_CATALOG'

# Top level directory for vectors to load
# The load will recurse in all sub-directories !
VECTOR_DATA='/media/sf_Workshop_Files/data/04-loading'

# List of file types to load
VECTOR_PATTERN=['.json']

# Number of parallel processes to use
NUM_PROCESSES=2

# Load parameters
LOAD_PARAMS=' -overwrite -lco SRID=4326 -lco DIM=2 -lco GEOMETRY_NAME=geom -lco SPATIAL_INDEX=NO -lco ADD_LAYER_GTYPE=NO -lco LAUNDER=YES'

# Logging level. Specify as one of:
#   logging.DEBUG
#   logging.INFO
#   logging.WARNING
#   logging.ERROR
#   logging.CRITICAL
LOGGING_LEVEL=logging.DEBUG

# GDAL debugging
CPL_DEBUG='OFF'
# GDAL memory use (in MB)
GDAL_CACHEMAX='512'

# Catalog creation script
CATALOG_CREATION_DDL='create_vector_catalog.sql'
