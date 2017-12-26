/*
  Each row in the table corresponds to one raster file and contains the following:
  
  Unique identifier
  Full path and name of the raster file
  The full time stamp when the loading of that file started
  Full path and name of the raster file
  Type of raster (derived from the file type)
  Name of raster table
  Timestamp when the load started
  Size (in bytes) of the input raster file
  Status of the file, as one of: new (not loaded yet), loaded, or failed
  Duration of the load (in seconds)
  Name of the RDT table used
  Raster ID in the RDT table
  Full standard output
  Full error output
*/

create table raster_catalog (
  id              number generated always as identity primary key,
  file_path       varchar2(256),
  file_name       varchar2(80),
  file_type       varchar2(10),
  file_size       number,
  status          char(1) check (status in ('N','L','F')) not null,
  raster_table    varchar2(30),
  load_timestamp  timestamp,
  load_duration   number,
  rasterdatatable varchar2(30),
  rasterid        number,
  load_output     clob,
  load_error      clob,
  unique (file_path,file_name)
);
