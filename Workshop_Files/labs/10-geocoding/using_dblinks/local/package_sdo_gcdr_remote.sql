create or replace package sdo_gcdr_remote as

function geocode (
  username                       varchar2,
  addr_lines                     sdo_keywordarray,
  country                        varchar2,
  match_mode                     varchar2
)
return sdo_geo_addr;

function geocode_addr (
  gc_username                    varchar2,
  address                        sdo_geo_addr
)
return sdo_geo_addr;

function reverse_geocode (
  username                       varchar2,
  location                       sdo_geometry,
  country                        varchar2
)
return sdo_geo_addr;

end;
/
show error

