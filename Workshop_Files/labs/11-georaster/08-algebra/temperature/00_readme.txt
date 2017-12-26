


1. Creating the tables

01_create_tables.sql

The process uses two raster tables:

PREP_TEMP_TABLE = used to prepare the data before it can be used
TEMPERATURE_TABLE = holds the data

2. Loading the rasters

The



This is an example of raster algebra processing in GeoRaster.

The initial data is a collection of 35 years of global temperature data.

The values are in Kelvin but they can be converted to Fahreneith using the script convert2f.sql

The script analyse.sql generate the Anomaly per Month by calculating the accumulated distance from the average on each month.

Execute the script is that order:

create_table.sql

import_data.sql

convert2f.sql

analyse.sql

expand.sql

colormap.sql

You can get the source data and scripts from: nsh2110267:/scratch/spatial/ivan/temperature_demo.zip

All you need to do is to fix the folder path on import_data.sql, replacing all the 3 occurrences of  "/scratch/ilucena/Demos/temperature/" to the folder where you have unzipped the data and run "all.sql". See what it does:
start create_tables     -- Create tables PREP_TEMP_table and TEMPERATURE_table
start import_data       -- Import rss_tb_maps_ch_tlt_v3_3_temperature.tif to PREP_TEMP_table
start georef            -- Replace West/East hemisphere and georeference on PREP_TEMP_table
start convert2f         -- Convert values in Kelvin to Fahrenheit using Raster Algebra
start expand            -- Expand the image
start averages          -- Calculate the monthly average temperature using Raster Algebra
start anomalies         -- Calculate temperature anomalies using Raster Algebra
start colormap          -- Create color map
start add_mask          -- Add Land mask
Once you have everything ready, I suggest you play with the colormap.sql to create something you would like best.

The data comes from http://www.remss.com.

The mask (WORLD_BORDERS.tif) was generate with gdal_rasterize and a shape file with country borders.

Please let me know if that works for you or how can we improve it.

