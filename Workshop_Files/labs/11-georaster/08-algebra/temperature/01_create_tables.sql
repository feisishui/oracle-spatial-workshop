--------------------------------------------------------------------------------
-- Create data preparation tables PREP_TEMP_table(and _RDT) to hold preparation data
--------------------------------------------------------------------------------
create table PREP_TEMP_table(
  id          number primary key,
  name        varchar2(64),
  begindate   date,
  enddate     date,
  raster      sdo_georaster
);

create table PREP_TEMP_rdt of sdo_raster (
  primary key ( 
    rasterID, 
    pyramidLevel, 
    bandBlockNumber,
    rowBlockNumber,
    columnBlockNumber 
  ) 
)
LOB(rasterBlock) STORE AS SECUREFILE (CACHE NOLOGGING);

--------------------------------------------------------------------------------
-- Create demonstration tables TEMPERATURE_table(and _RDT) to hold the temperature data
--------------------------------------------------------------------------------
create table TEMPERATURE_table(
  id          number primary key,
  name        varchar2(64),
  begindate   date,
  enddate     date,
  raster      sdo_georaster
);

create table TEMPERATURE_rdt of sdo_raster (
  primary key ( 
    rasterID, 
    pyramidLevel, 
    bandBlockNumber,
    rowBlockNumber,
    columnBlockNumber 
  ) 
)
LOB(rasterBlock) STORE AS SECUREFILE (CACHE NOLOGGING);
