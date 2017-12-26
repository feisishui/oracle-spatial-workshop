=========================================================================
Georaster
=========================================================================

In this lab you will be loading a set of TIFF images into your database.
You will have the choice of loading the rasters using the java loader
("push" method) or using the PL/SQL interface ("pull" method), or also using GDAL.

-------------------------------------------------------------------------
Overview of source data:
-------------------------------------------------------------------------

* Four GeoTIFF satellite images of San Francisco
------------------------------------------------:

  SF1.TIF
  SF2.TIF
  SF3.TIF
  SF4.TIF

Each tiff file is accompanied by a TIFF "world file" that contains its georeferencing parameters.

The size of each image is 4299 x 4299 pixels, in 3 bands (RGB) = 54 MB

The four images are aligned and form a seamless coverage:

  +-----+-----+
  |  1  |  3  |
  +-----+-----+
  |  2  |  4  |
  +-----+-----+

The same images are also provided in JPEG format.

* Street level information
--------------------------

You will also import two tables:

US_STREETS = streets of San Francisco for the area covered by the rasters
US_POIS = points of interests (banks, restaurants, hotels, etc)

This data will be used to illustrate the overlaying of vectors onto rasters by MapViewer.

-------------------------------------------------------------------------
Preparation:
-------------------------------------------------------------------------

The raster loader and viewer are only provided with the installation of the examples CD (companion CD in
Oracle 10g). If you installed the examples, you will find the raster tools in
  $ORACLE_HOME/md/demo/georaster/java (file georaster_tools.jar).

If you did not load the example CD, then you can copy the examples from the kits directory (kits/examples_cd)

For our labs, you will find the georaster_tools.jar in the libs directory.

-------------------------------------------------------------------------
1) Prepare: Create and populate the raster tables
-------------------------------------------------------------------------

Create the georaster table (US_RASTERS)

  01-CREATE_GEORASTER_TABLE.SQL

Create the raster data table (US_RASTERS_RDT_01)

  02-CREATE_RDTS.SQL


-------------------------------------------------------------------------
2) Import: Loading the rasters
-------------------------------------------------------------------------

2.1) Loading the rasters using GDAL
------------------------------------

Get information about the input files (using GDALINFO)

  01-GET_FILE_DETAILS.BAT

  This uses commands like the following:

  gdalinfo ..\..\..\..\data\11-georaster\sf1.tif


Load the rasters (using GDAL_TRANSLATE)

  02-LOAD_RASTERS BAT

  This uses commands like the following:

  gdal_translate -of georaster %RASTER_DATA%\sf1.tif georaster:scott/tiger,,us_rasters,georaster -co "insert=values (1, 'sf1.tif', 'Aerial photo San Francisco 1',sdo_geor.init('us_rasters_rdt_01', 1),null,null)" -co blockxsize=512 -co blockysize=512 -co blockbsize=3 -co interleave=bip -co srid=26943


Get information about the rasters just loaded (using GDALINFO)

  03-GET_RASTER_DETAILS.BAT

  This uses commands like the following:

  gdalinfo georaster:scott/tiger,,us_rasters,georaster,georid=1


Generate the pyramid on the rasters just loaded (using GDALADDO)

  04-GENERATE_PYRAMIDS.BAT

  This uses commands like the following:

  gdaladdo -r nearest georaster:scott/tiger,,us_rasters,georaster,georid=1 2 4 8 16 32


Export the rasters out to JPEG files (using GDAL_TRANSLATE)

  05_EXPORT_RASTERS.BAT

  This uses commands like the following:

  gdal_translate -of jpeg georaster:scott/tiger,,us_rasters,georaster,georid=1 %RASTER_DATA%\sf1.jpg -co worldfile=YES

2.3) Loading the rasters using the java command line tool ("push" method)
-------------------------------------------------------------------------

Initialize the rasters

  01-INITIALIZE_RASTERS.SQL

  This script populates the rasters with the pointers to the RDT

Load the rasters

  02-LOAD_RASTERS.BAT

  This uses the java loader to load all images into the table US_RASTERS. The parameters used are:
    blocking=true           = divide the raster into blocks
    blockSize=(512,512)     = blocks are 512 by 512 pixels by 3 bands
    spatialExtent=true      = compute the spatial extent
    compression=none        = no compression

  NOTE: Modify the script to match your oracle home, database connection parameters, username, etc.

  You can also experiment with a number of alternatives:

  02-LOAD_RASTERS_BLOCK.BAT
  = same as above but uses a better block size of 440x440, causing no padding.

  02-LOAD_RASTERS_GEOTIFF.BAT
  = load the tiffs as GeoTIFF and compress them in JPEG

  02-LOAD_RASTERS_JPEG_DIRECT.BAT
  = load the JPEGs unblocked. This loads them as-is, without decompression and recomression.


Generate resolution pyramids

  03-GENERATE_PYRAMIDS.SQL

  This script generates a 4-level pyramid on the four rasters just loaded.

  NOTE: this operation needs about 100 MB of temporary space. Make sure the temporary tablespace is large enough and/or extensible. The following command makes the tablespace autoxtensible:

   SQL> alter database tempfile 'D:\DATABASES\ORCL111\DATA\TEMP01.DBF' autoextend on;


2.4) Loading the rasters using the PL/SQL API
---------------------------------------------

Initialize the rasters

  01-INITIALIZE_RASTERS.SQL

  This script populates the rasters with the pointers to the RDT

Grant access to the rasters

  02_GRANT_RIGHTS_FOR_LOAD.SQL

  Run this script as system. It grants the necessary rights to allow the database to access the TIF files.
  NOTE: First modify the script to match the place where you store the TIFF files.

Load the rasters

  03-LOAD_RASTERS.SQL

  This script initializes, loads and pyramids each of the rasters. It records the time spent for the loading and pyramiding of each raster.

Revoke access to the rasters

  04-REVOKE_RIGHTS.SQL

  Run this script as system. It revokes the necessary rights to allow the database to access the TIF files.
  NOTE: First modify the script to match the place where you store the TIFF files.


-------------------------------------------------------------------------
3) Setup spatial indexing
-------------------------------------------------------------------------

Setup spatial metadata

  01-SET_SPATIAL_METADATA.SQL

  This sets up the spatial metadata (USER_SDO_GEOM_METADATA) for the spatial extents of the images.

Create spatial index

  02-CREATE_SPATIAL_INDEX.SQL

  This creates the spatial index on the spatial extents.

-------------------------------------------------------------------------
4) Examine the results
-------------------------------------------------------------------------

Get details about the loaded rasters

  01-GET_RASTER_DETAILS.SQL

  Uses various "get" functions of the SDO_GEOR package.to obtain information about the
  rasters: cell depth, compression, pyramid levels, etc.

Get details about the raster storage

  02-GET_RDT_SUMMARY.SQL

  Query the RDT and return the sizes and number of blocks of the rasters.

-------------------------------------------------------------------------
5) View the rasters
-------------------------------------------------------------------------

Use the raster viewer to see the loaded rasters

  05-VIEWER.BAT

  NOTE: Modify the script to match your oracle home

-------------------------------------------------------------------------
6) Using Mapviewer
-------------------------------------------------------------------------

Load some street-level information

  01_IMPORT_STREETS.BAT

  This job imports the US_STREETS and US_POIS tables

Load styles for MapViewer

  02_LOAD_STYLES.SQL

  This script will load some styles and themes to illustratre the
  combination of vectors and rasters

  L.US_STREETS = a line style for the streets
  T.US_STREETS = a label style for the streets
  M.US_POIS = a marker style for the pois
  T.US_POIS = a label style for the pois

  US_STREETS = a theme for the streets
  US_POIS = a theme for the POIs
  US_RASTERS = a theme for the rasters

  US_RASTER_MAP = a basemap that combines the rasters, streets and POIs

-------------------------------------------------------------------------
7) Performing Raster Algebra
-------------------------------------------------------------------------


