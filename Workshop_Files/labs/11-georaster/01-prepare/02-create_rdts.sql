CREATE TABLE us_rasters_rdt_01 OF sdo_raster (
  PRIMARY KEY (
     rasterId, pyramidLevel, bandBlockNumber,
     rowBlockNumber, columnBlockNumber)
)
LOB (rasterblock) STORE AS SECUREFILE (NOCACHE NOLOGGING);
