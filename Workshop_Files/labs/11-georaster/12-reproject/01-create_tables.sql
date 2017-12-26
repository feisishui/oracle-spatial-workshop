create table us_rasters_3857 (
  georid              number primary key,
  source_file         varchar2(80),
  description         varchar2(256),
  georaster           sdo_georaster,
  load_duration       number,
  pyramid_duration    number,
  transform_duration  number
);

CREATE TABLE us_rasters_3857_rdt_01 OF sdo_raster (
  PRIMARY KEY (
     rasterId, pyramidLevel, bandBlockNumber,
     rowBlockNumber, columnBlockNumber)
)
LOB (rasterblock) STORE AS SECUREFILE (NOCACHE NOLOGGING);
