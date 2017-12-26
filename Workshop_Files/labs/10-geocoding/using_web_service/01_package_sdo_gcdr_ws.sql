create or replace package sdo_gcdr_ws 
as

----------------------------------------------------------------------------------
-- Enable / disable tracing
----------------------------------------------------------------------------------
procedure set_trace (
  enabled        varchar2
);

----------------------------------------------------------------------------------
-- Get/set the URL of the geocoding service to call
----------------------------------------------------------------------------------
procedure set_url (
  url            varchar2
);

function get_url 
return varchar2;

----------------------------------------------------------------------------------
-- Get/set the host of the proxy to use
----------------------------------------------------------------------------------
procedure set_proxy (
  proxy_host     varchar2
);

function get_proxy 
return varchar2;

----------------------------------------------------------------------------------
-- Get/set the language to use for reverse geocodes
----------------------------------------------------------------------------------
procedure set_language (
  language_     varchar2
);

function get_language
return varchar2;

----------------------------------------------------------------------------------
-- Perform the geocode_all() call. 
----------------------------------------------------------------------------------
function geocode_all (
  addr_lines     sdo_keywordarray,
  country        varchar2,
  match_mode     varchar2
)
return sdo_addr_array 
deterministic;

----------------------------------------------------------------------------------
-- Perform the geocode() call. 
----------------------------------------------------------------------------------
function geocode (
  addr_lines     sdo_keywordarray,
  country        varchar2,
  match_mode     varchar2
)
return sdo_geo_addr
deterministic;

----------------------------------------------------------------------------------
-- Perform the geocode_addr_all() call. 
----------------------------------------------------------------------------------
function geocode_addr_all (
  address        sdo_geo_addr
)
return sdo_addr_array
deterministic;

----------------------------------------------------------------------------------
-- Perform the geocode_addr() call. 
----------------------------------------------------------------------------------
function geocode_addr (
  address        sdo_geo_addr
)
return sdo_geo_addr
deterministic;

----------------------------------------------------------------------------------
-- Perform the geocode_as_geometry() call. 
----------------------------------------------------------------------------------
function geocode_as_geometry (
  addr_lines     sdo_keywordarray,
  country        varchar2
)
return sdo_geometry
deterministic;

----------------------------------------------------------------------------------
-- Perform the reverse_geocode() call. 
----------------------------------------------------------------------------------

function reverse_geocode (
  location       sdo_geometry,
  country        varchar2 default null
)
return sdo_geo_addr
deterministic;

function reverse_geocode (
  longitude      number,
  latitude       number,
  country        varchar2 default null
)
return sdo_geo_addr
deterministic;

function reverse_geocode (
  longitude      number,
  latitude       number,
  srid           number,
  country        varchar2 default null
)
return sdo_geo_addr
deterministic;

end;
/
show error