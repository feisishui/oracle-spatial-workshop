==========================================================
Using GDAL
==========================================================

1) Get information about the shape files

01_CHECK_SHAPES


2) Load the shape files using GDAL.

02_LOAD_SHAPEFILES.BAT

This will load the following two tables:

WORLD_CONTINENTS    111 rows
WORLD_COUNTRIES     251 rows

Note: if the tables already exist, you must drop them first and clear the spatial metadata (99_CLEANUP.SQL)


3) Get information about the database tables

03_CHECK_DATABASE_TABLES.BAT


4) Export database tables to shape files

04_EXPORT_TO_SHAPES.BAT


5) Export database tables to mapinfo "TAB" files

05_EXPORT_TO_MAPINFO.BAT

