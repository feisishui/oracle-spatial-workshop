create table us_rasters_mosaic (
  georid            number primary key,
  georaster         sdo_georaster
);
CREATE TABLE us_rasters_mosaic_rdt_01 OF sdo_raster (
  PRIMARY KEY (
     rasterId, pyramidLevel, bandBlockNumber,
     rowBlockNumber, columnBlockNumber)
)
LOB (rasterblock) STORE AS SECUREFILE (NOCACHE NOLOGGING);

