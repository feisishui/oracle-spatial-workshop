create table us_rasters (
  georid              number primary key,
  source_file         varchar2(80),
  description         varchar2(256),
  georaster           sdo_georaster,
  load_duration       number,
  pyramid_duration    number,
  transform_duration  number
);
